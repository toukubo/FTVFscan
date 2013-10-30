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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    }];
    NSLog(@"info: %@",info);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    returnFromPicker = YES;
    [galleryPicker dismissViewControllerAnimated:NO completion:^{}];
    self.tabBarController.selectedIndex = 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
