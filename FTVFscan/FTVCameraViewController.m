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

@interface FTVCameraViewController ()
{
    FTVAppDelegate              *appDelegate;
    BOOL                        returnFromPicker;      // Workaround while this workflow is not completed
    UIImagePickerController     *photoPicker;
    NSString                    *redirectUrl;
}

@end

@implementation FTVCameraViewController
@synthesize popoverHolder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    if (!photoPicker) {
        photoPicker = [[UIImagePickerController alloc] init];
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        
        [photoPicker setSourceType: sourceType];
        
        [photoPicker setMediaTypes: @[(NSString *)kUTTypeImage]];
    }
    
    appDelegate = (FTVAppDelegate *)[UIApplication sharedApplication].delegate;
    returnFromPicker = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if(photoPicker && !returnFromPicker){
        photoPicker.delegate = self;
        
        if (IS_IPAD) {
            // http://stackoverflow.com/a/5546679
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:photoPicker];
            self.popoverHolder = popover;
            
            popover.popoverContentSize = self.view.frame.size;
            int tabBarItemWidth = self.tabBarController.tabBar.frame.size.width / [self.tabBarController.tabBar.items count];
            int x = tabBarItemWidth * 2;
            
            CGRect rect = CGRectMake(x, 0, tabBarItemWidth, self.view.frameSizeHeight - self.tabBarController.tabBar.frame.size.height);
            
            [self.popoverHolder presentPopoverFromRect:rect
                                                inView:self.tabBarController.tabBar
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:NO];
        } else {
            [self presentViewController:photoPicker
                               animated:NO
                             completion:nil];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (returnFromPicker) returnFromPicker = NO;
    
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma UIImagePickerController delegate methods
// Here we have an image from camera for later use
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    returnFromPicker = YES;
    
    [photoPicker dismissViewControllerAnimated:NO completion:^{
        UIImage *pickedImage = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
        DLog(@"IMG pre proessed: W - %f, H - %f", pickedImage.size.width, pickedImage.size.height);
        
        for (int i = 0; i < TEST_TIME; i++) {
            NSDate *start = [NSDate date];
            pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
            NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
            NSLog(@"imageResize Execution Time: %f", executionTime);
        }
        
        // TODO: should we use png or others?
        for (int i = 0; i < TEST_TIME; i++) {
            NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];
            
            NSData *imageData = UIImagePNGRepresentation(pickedImage);
            
            DLog(@"image data size - %d KB", imageData.length / 1024);
            
            if (IsEmpty(brand_slug) || [brand_slug isEqualToString:@"failure"]) {
                [appDelegate showModalPopupWindow];
            } else {
                NSDate *start = [NSDate date];
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
                
                
                DLog(@"IMG: W - %f, H - %f", pickedImage.size.width, pickedImage.size.height);
            }
        }
    }];
    //    DLog(@"info: %@",info);
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
// user pressed "Cancel" So returning to first tab of the app
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    returnFromPicker = YES;
    [photoPicker dismissViewControllerAnimated:NO completion:^{
    }];
    self.tabBarController.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
