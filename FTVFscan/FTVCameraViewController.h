//
//  FTVCameraViewController.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTVCameraViewController : UIViewController <UINavigationControllerDelegate>

@property (strong) UIPopoverController *popoverHolder;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *cameraView;

-(IBAction)OpenMenu:(id)sender;
@end
