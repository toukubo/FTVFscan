//
//  FTVCustomNavigationController.h
//  FTVFscan
//
//  Created by Ganapathi Rallapalli on 22/11/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@interface FTVCustomNavigationController : UIViewController{
    
}
//-(IBAction)homeAction:(id)sender;
//-(IBAction)cameraAction:(id)sender;
//-(IBAction)OpenMenu:(id)sender;
-(void)homeAction;
-(void)cameraAction;
-(void)openMenu;
-(void)setHomeCameraMenuNavigations:(UIViewController *)vc;
-(void)setHomeMenuNavigations:(UIViewController *)vc;
-(void)setBackCameraMenuNavigations:(UIViewController *)vc;
-(void)setTitleNavigation:(UIViewController *)vc;

@property (nonatomic, retain) LoadingView *loadingView;
- (void)navBarSlideLeft;

@end
