//
//  FTVCameraViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <ASIFormDataRequest.h>

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
        
        //TODO: we can resize the image later, before post to the remote, so it will not harless the user experience.
        pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
        
        // In production remove imageView from storyboard and open new workflow view there in main thread
        self.imageView.contentMode = UIViewContentModeCenter;   // disbale auto enlarge
        self.imageView.image = pickedImage;
        
        NSData *imageData = UIImagePNGRepresentation(pickedImage);

        [ self postData: imageData withBrand:@"gucci"];
        
        [FTVImageProcEngine executeApi:pickedImage];
        
        
        DLog(@"IMG: W - %f, H - %f", pickedImage.size.width, pickedImage.size.height);
    }];
    DLog(@"info: %@",info);
}
- (void)openSafari:(NSString *)id
{
    NSString *req_url = [NSString stringWithFormat:@"%@%@%@%@%@", BASEURL,@"/scan/scan.php?deviceid=",[FTVUser getId],@"&id=",id];
    NSURL *url = [NSURL URLWithString:req_url];
    DLog(req_url);
    if (![[UIApplication sharedApplication] openURL:url])
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);

    
}
-(void)postData:(NSData *)photoData withBrand:(NSString *) brand_slug {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", BASEURL, @"scan/post.php"];
    DLog(urlStr);
    ASIFormDataRequest* req = [ASIFormDataRequest
                               requestWithURL:[NSURL URLWithString:urlStr]];
    [req setTimeOutSeconds:120];
    [req addPostValue:[FTVUser getId] forKey:@"user_id"];
    [req addPostValue:brand_slug forKey:@"brand_slug"];

    [req setData:photoData withFileName:@"image.png" andContentType:@"image/png" forKey:@"image"];
    req.delegate  =  self;
    req.didFinishSelector = @selector(postSucceeded:);
    req.didFailSelector = @selector(postFaild:);
    req.defaultResponseEncoding = NSUTF8StringEncoding;
    [req startAsynchronous];
}
-(void)postSucceeded:(ASIHTTPRequest*)req {
    NSString* resString = [req responseString];
    DLog(resString);
    [ self openSafari:resString];

}
-(void)postFaild:(ASIHTTPRequest*)req {
    DLog(@"failed");
//    NSString* resString = [req responseString];
//    DLog(resString);
    /// self openSafari:@"17"];
    
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

@end
