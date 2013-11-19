//
//  FTVCameraViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "FTVCameraViewController.h"
#import "FTVDelayJobWebViewController.h"

#import "AVCamViewController.h"

@interface FTVCameraViewController () <AVCamViewControllerDelegate>
{
    FTVAppDelegate              *appDelegate;
    
    BOOL                        returnFromPicker;      // Workaround while this workflow is not completed
    NSString                    *redirectUrl;
}

@end

@implementation FTVCameraViewController
@synthesize popoverHolder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    appDelegate = (FTVAppDelegate *)[UIApplication sharedApplication].delegate;
    returnFromPicker = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!returnFromPicker){
        AVCamViewController *avCamera = [[AVCamViewController alloc] init];
        [avCamera setDelegate:self];
        
        [self presentViewController:avCamera animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (returnFromPicker) {
        returnFromPicker = NO;
    }
    
    [SVProgressHUD dismiss];
}

- (void)doImageProcessInBackgroundWithPath:(NSString*)imagePath
{
    UIImage *pickedImage = [UIImage imageWithContentsOfFile:imagePath];
    
    DLog(@"IMG pre proessed: W - %0.f px, H - %0.f px", pickedImage.size.width, pickedImage.size.height);
    
    for (int i = 0; i < TEST_TIME; i++) {
        NSDate *start = [NSDate date];
        pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
        NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
        NSLog(@"imageResize Execution Time: %f", executionTime);
    }
    
    for (int i = 0; i < TEST_TIME; i++) {
        NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];
        
        NSData *imageData = UIImagePNGRepresentation(pickedImage);
        
        DLog(@"image data size - %d KB", imageData.length / 1024);
        
        if (IsEmpty(brand_slug) || [brand_slug isEqualToString:@"failure"]) {
            [appDelegate performSelectorOnMainThread:@selector(showModalPopupWindow) withObject:nil waitUntilDone:NO];
        } else {
            NSDate *start = [NSDate date];
            // no need to post data if BRAND was failure
            [FTVImageProcEngine postData:imageData
                               withBrand:brand_slug
                          withStartBlock:^{
                          } withFinishBlock:^(BOOL success, NSString *resp) {
                              if (success) {
                                  NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
                                  NSLog(@"postData Execution Time: %f", executionTime);
                                  redirectUrl = [FTVImageProcEngine encapsulateById:resp];
                                  if (![redirectUrl isMalform]) {
                                      [self performSelectorOnMainThread:@selector(switchSceneToResultController) withObject:nil waitUntilDone:NO];
                                  }
                              }
                          } withFailedBlock:^(BOOL success, NSString *resp) {
                          }];
            
            
            DLog(@"IMG: W - %f, H - %f", pickedImage.size.width, pickedImage.size.height);
        }
    }
}

- (void)switchSceneToResultController
{
    [self performSegueWithIdentifier:@"presentDelayJobWebViewController" sender:self];
}
#pragma mark - AVCamViewControllerDelegate
- (void)didFinishedTakenPictureWithPath:(NSString*)imagePath
{
    returnFromPicker = YES;
    
    [SVProgressHUD show];
    [self performSelectorInBackground:@selector(doImageProcessInBackgroundWithPath:) withObject:imagePath];
}

- (void)didCancelCamera
{
    // TODO: should we support cancel ?
    returnFromPicker = YES;
//    self.tabBarController.selectedIndex = 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentDelayJobWebViewController"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[FTVDelayJobWebViewController class]]) {
                ((FTVDelayJobWebViewController*)vc).redirectUrl = redirectUrl;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
