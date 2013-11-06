//
//  FTVGalleryViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVGalleryViewController.h"
#import "FTVAppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface FTVGalleryViewController ()
{
    FTVAppDelegate *appDelegate;
    
    BOOL returnFromPicker;
    
    UIImagePickerController *galleryPicker;
}

@end

@implementation FTVGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
        

    }];
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

@end
