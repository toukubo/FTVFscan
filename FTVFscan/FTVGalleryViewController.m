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
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (returnFromPicker) returnFromPicker = NO;
    
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma UIImagePickerController delegate methods
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    returnFromPicker = YES;
//    [galleryPicker dismissViewControllerAnimated:NO completion:^{
//        // Got image from picker
//        // Should do something with it )))
//        UIImage *pickedImage = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
//        
//        NSDate *start = [NSDate date];
//        pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
//        NSData *imageData = UIImagePNGRepresentation(pickedImage);
//        
//        NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];
//        NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
//        NSLog(@"executeApi Execution Time: %f", executionTime);
//        
//        if (IsEmpty(brand_slug) || [brand_slug isEqualToString:@"failure"]) {
//            [appDelegate showModalPopupWindow];
//        } else {
//            // no need to post data if BRAND was failure
//            [FTVImageProcEngine postData:imageData
//                               withBrand:brand_slug
//                          withStartBlock:^{
//                              [SVProgressHUD show];
//                          } withFinishBlock:^(BOOL success, NSString *resp) {
//                              if (success) {
//                                  [SVProgressHUD dismiss];
//                                  
//                                  NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
//                                  NSLog(@"postData Execution Time: %f", executionTime);
//                                  
//                                  redirectUrl = [FTVImageProcEngine encapsulateById:resp];
//                                  if (![redirectUrl isMalform]) {
//                                      [self performSegueWithIdentifier:@"presentDelayJobWebViewController" sender:self];
//                                  }
//                              } else {
//                                  [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_resp_malform", @"Malform")];
//                              }
//                          } withFailedBlock:^(BOOL success, NSString *resp) {
//                              [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_resp_error", @"Error")];
//                          }];
//        }
//    }];
//    
//    
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    }
//}
//


- (void)generateRedirectURL:(int)index
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
        [appDelegate showModalPopupWindow];
    } else {
        // no need to post data if BRAND was failure
        [FTVImageProcEngine postData:imageData
                           withBrand:brand_slug
                      withStartBlock:^{
                          [SVProgressHUD show];
                      } withFinishBlock:^(BOOL success, NSString *resp) {
                          if (success) {
                              [SVProgressHUD dismiss];
                              
                              NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
                              NSLog(@"postData Execution Time: %f", executionTime);
                              
                              redirectUrl = [FTVImageProcEngine encapsulateById:resp];
                              if (![redirectUrl isMalform]) {
                                  [self performSegueWithIdentifier:@"presentDelayJobWebViewController" sender:self];
                              }
                          } else {
                              [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_resp_malform", @"Malform")];
                          }
                      } withFailedBlock:^(BOOL success, NSString *resp) {
                          [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_resp_error", @"Error")];
                      }];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentDelayJobWebViewController"]) {
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        [self generateRedirectURL:selectedCell.row];
        UINavigationController *navigationController = segue.destinationViewController;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[FTVDelayJobWebViewController class]]) {
                ((FTVDelayJobWebViewController*)vc).redirectUrl = redirectUrl;
            }
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return self.assets.count;
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(IBAction)OpenMenu:(id)sender
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRightController:YES];
    
}


@end
