//
//  FTVGalleryViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "FTVGalleryViewController.h"
#import "FTVAppDelegate.h"
#import "FTVDelayJobWebViewController.h"

static const int kImageViewTag = 1;  // the image view inside the collection view cell prototype is tagged with "1"

@interface FTVGalleryViewController ()
{
    FTVAppDelegate              *appDelegate;
    BOOL                        returnFromPicker;
    NSString                    *redirectUrl;
}

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation FTVGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    appDelegate = (FTVAppDelegate *)[UIApplication sharedApplication].delegate;
    returnFromPicker = NO;
    
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.groups addObject:group];
            self.assetsGroup = self.groups[0];
            if (!self.assets) {
                _assets = [[NSMutableArray alloc] init];
            } else {
                [self.assets removeAllObjects];
            }
            
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    [self.assets addObject:result];
                }
            };
            
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
            [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
        }
        else
        {
            [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    //    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    NSUInteger groupTypes =  ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
    [super setHomeCameraMenuNavigations:self];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (returnFromPicker) returnFromPicker = NO;
    
    [self.loadingView performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper
- (void)laterJobAfterSelectedImageWithId:(int)index
{
    returnFromPicker = YES;
    
    // Got image from picker
    // Should do something with it )))
    ALAsset *asset = self.assets[index];
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    
    UIImage *pickedImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                               scale:[assetRepresentation scale]
                                         orientation:ALAssetOrientationUp];
    NSDate *start = [NSDate date];
    pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
    NSData *imageData = UIImagePNGRepresentation(pickedImage);
    
    NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];
    NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
    NSLog(@"executeApi Execution Time: %f", executionTime);
    
    if (IsEmpty(brand_slug) || [brand_slug isEqualToString:@"failure"]) {
        [appDelegate performSelectorOnMainThread:@selector(showModalPopupWindow) withObject:nil waitUntilDone:NO];
    } else {
        NSDate *start = [NSDate date];
        // no need to post data if BRAND was failure
        // step 1 - post brand slug, and get response for "id=xxx"
        [FTVImageProcEngine postWithBrand:brand_slug
                           withStartBlock:^{
                           } withFinishBlock:^(BOOL success, NSString *resp) {
                               if (success) {
                                   NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
                                   NSLog(@"postData Execution Time: %f", executionTime);
                                   
                                   // step 2 - post image data
                                   [FTVImageProcEngine postData:imageData
                                                      withBrand:brand_slug
                                                         withId:resp
                                                 withStartBlock:nil
                                                withFinishBlock:^(BOOL success, NSString *resp) {
                                                    // TODO: should we do some extra stuff here?
                                                } withFailedBlock:^(BOOL success, NSString *resp) {
                                                    //
                                                }];
                                   
                                   redirectUrl = [FTVImageProcEngine encapsulateById:resp];
                                   if (![redirectUrl isMalform]) {
//                                       [self performSelectorOnMainThread:@selector(switchSceneToResultController) withObject:nil waitUntilDone:NO];
                                       
                                       DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
                                       FTVDelayJobWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVDelayJobWebViewController"];
                                       controller.redirectUrl = redirectUrl;
                                       controller.ShowResultPage = YES;
                                       
                                       [menuController setRootController:controller animated:YES];
                                       [menuController showRootController:YES];
                                   }
                               }
                           } withFailedBlock:^(BOOL success, NSString *resp) {
                           }];
        
        DLog(@"IMG: W - %0.f px, H - %0.f px", pickedImage.size.width, pickedImage.size.height);
    }
}

- (void)switchSceneToResultController
{
    [self performSegueWithIdentifier:@"presentDelayJobWebViewController" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentDelayJobWebViewController"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[FTVDelayJobWebViewController class]]) {
                FTVDelayJobWebViewController *controller = ((FTVDelayJobWebViewController*)vc);
                controller.redirectUrl = redirectUrl;
                controller.ShowResultPage = YES;
                DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
                
                [menuController setRootController:controller animated:YES];
                [menuController showRootController:YES];
                

            }
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"photoCell";
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    ALAsset *asset = self.assets[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    // apply the image to the cell
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
    imageView.image = thumbnail;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self laterJobAfterSelectedImageWithId:indexPath.row];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - DDMenu stuff
-(IBAction)OpenMenu:(id)sender
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRightController:YES];
}
@end
