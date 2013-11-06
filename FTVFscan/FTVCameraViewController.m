//
//  FTVCameraViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "FTVCameraViewController.h"

@interface FTVCameraViewController ()
{
    FTVAppDelegate *appDelegate;
    
    // Workaround while this workflow is not completed
    BOOL returnFromPicker;
    
    UIImagePickerController *photoPicker;
}

@end

@implementation FTVCameraViewController

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
    
    if (!photoPicker) {
        photoPicker = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
        [photoPicker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
#else
        [photoPicker setSourceType: UIImagePickerControllerSourceTypeCamera];
        //        [picker setCameraOverlayView:self.customCameraOverlayView];
#endif
        
        [photoPicker setMediaTypes: @[(NSString *)kUTTypeImage]];
    }
    
    appDelegate = (FTVAppDelegate *)[UIApplication sharedApplication].delegate;
    returnFromPicker = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if(photoPicker && !returnFromPicker){
        photoPicker.delegate = self;
        [self presentViewController:photoPicker animated:NO completion:nil];
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
        self.imageView.contentMode = UIViewContentModeCenter;   // disbale auto enlarge
        self.imageView.image = pickedImage;
        
        // TODO: should we use png or others?
        
        NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];

        NSData *imageData = UIImagePNGRepresentation(pickedImage);

        [ FTVImageProcEngine postData:imageData
                            withBrand:brand_slug
                       withStartBlock:^{
                           // TODO: write custom logic here
                           // show HUD or something
                       } withFinishBlock:^(BOOL success, NSString *resp) {
                           // TODO: write custom logic here
                       } withFailedBlock:^(BOOL success, NSString *resp) {
                           // TODO: write custom logic here
                       }
         ];
        
        
        
        DLog(@"IMG: W - %f, H - %f", pickedImage.size.width, pickedImage.size.height);
    }];
    DLog(@"info: %@",info);
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
