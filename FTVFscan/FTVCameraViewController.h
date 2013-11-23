//
//  FTVCameraViewController.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTVCustomNavigationController.h"

@interface FTVCameraViewController : FTVCustomNavigationController <UINavigationControllerDelegate>

@property (strong) UIPopoverController *popoverHolder;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

-(IBAction)OpenMenu:(id)sender;
@end
