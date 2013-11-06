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
    FTVAppDelegate *appDelegate;
    
    BOOL returnFromPicker;
    
    UIImagePickerController *galleryPicker;
    
    NSString                *redirectUrl;
}

@end

@implementation FTVGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    appDelegate = (FTVAppDelegate *)[UIApplication sharedApplication].delegate;
    returnFromPicker = NO;
    
    if (!galleryPicker) {
        galleryPicker = [[UIImagePickerController alloc] init];
        [galleryPicker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        [galleryPicker setMediaTypes: @[(NSString *)kUTTypeImage]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if(galleryPicker && !returnFromPicker){
        galleryPicker.delegate = self;
        [self presentViewController:galleryPicker animated:NO completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (returnFromPicker)
        returnFromPicker = NO;
}

#pragma mark -
#pragma UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    returnFromPicker = YES;
    [galleryPicker dismissViewControllerAnimated:NO completion:^{
        // Got image from picker
        // Should do something with it )))
        UIImage *pickedImage = (UIImage *)info[@"UIImagePickerControllerOriginalImage"];
        
        //TODO: we can resize the image later, before post to the remote, so it will not harless the user experience.
        pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
        
        NSData *imageData = UIImagePNGRepresentation(pickedImage);
        
        NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];
        
        [FTVImageProcEngine postData:imageData
                           withBrand:brand_slug
                      withStartBlock:^{
                          // TODO: write custom logic here
                          // show HUD or something
//                          [SVProgressHUD showWithStatus:NSLocalizedString(@"hud_loading", @"Loading")];
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
    }];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    returnFromPicker = YES;
    
    [galleryPicker dismissViewControllerAnimated:NO completion:nil];
    
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
