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
    FTVAppDelegate *appDelegate;
    
    // Workaround while this workflow is not completed
    BOOL returnFromPicker;
    
    UIImagePickerController *photoPicker;
    
    NSString                *redirectUrl;
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
    if (returnFromPicker)
        returnFromPicker = NO;
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
        
        //TODO: we can resize the image later, before post to the remote, so it will not harless the user experience.
        pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
        
        // In production remove imageView from storyboard and open new workflow view there in main thread
        //        self.imageView.contentMode = UIViewContentModeCenter;   // disbale auto enlarge
        //        self.imageView.image = pickedImage;
        
        // TODO: should we use png or others?
        
        NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];
        
        NSData *imageData = UIImagePNGRepresentation(pickedImage);
//        if ( brand_slug == nil){
//            
//        }else{
            [ FTVImageProcEngine postData:imageData
                                withBrand:brand_slug
                           withStartBlock:^{
                               // TODO: write custom logic here
                               // show HUD or something
//                               [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_loading", @"Loading")];
                               [SVProgressHUD show];
                           } withFinishBlock:^(BOOL success, NSString *resp) {
                               if (success) {
                                   redirectUrl = [FTVImageProcEngine encapsulateById:resp];
                                   if (![redirectUrl isMalform]) {
                                       [self performSegueWithIdentifier:@"presentDelayJobWebViewController" sender:self];
                                       [SVProgressHUD dismiss];
                                   }
                               } else {
                                   [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_resp_malform", @"Malform")];
                               }
                           } withFailedBlock:^(BOOL success, NSString *resp) {
                               [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_resp_error", @"Error")];
                           }];
//        }
        
        DLog(@"IMG: W - %f, H - %f", pickedImage.size.width, pickedImage.size.height);
    }];
    DLog(@"info: %@",info);
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
