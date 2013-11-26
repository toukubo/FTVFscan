//
//  FTVCameraViewController.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FTVCamOverlayView.h"

#import "FTVCustomNavigationController.h"

@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface FTVCameraViewController : FTVCustomNavigationController <FTVCamOverlayViewDelegate, UINavigationControllerDelegate>
{
    FTVCamOverlayView       *overlayView;
    
    UIImageView             *indicator;
    
    UIButton                *stillButton;
    UIButton                *homeButton;
}

@property (nonatomic, retain) AVCamCaptureManager           *captureManager;
@property (nonatomic, retain) IBOutlet UIView               *videoPreviewView;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer    *captureVideoPreviewLayer;
@property (nonatomic, assign) id                            delegate;


@property (strong) UIPopoverController *popoverHolder;

- (IBAction)openHome:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *cameraView;

- (IBAction)openGallery:(id)sender;

//-(IBAction)OpenMenu:(id)sender;
@end
