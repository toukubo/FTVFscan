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
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;

}
//-(IBAction)homeAction:(id)sender;
//-(IBAction)cameraAction:(id)sender;
//-(IBAction)OpenMenu:(id)sender;
-(void)backAction;
-(void)homeAction;
-(void)cameraAction;
-(void)openMenu;
-(void)setHomeCameraMenuNavigations:(UIViewController *)vc;
-(void)setHomeMenuNavigations:(UIViewController *)vc;
-(void)setBackCameraMenuNavigations:(UIViewController *)vc;
-(void)setTitleNavigation:(UIViewController *)vc;
-(void)setBackCameraNavigations:(UIViewController *)vc;
-(void)setBackButton:(UIView *)view vc:(UIViewController *)vc;
-(void)setCameraMenuNavigations:(UIViewController *)vc;
-(void)setFirstCameraButton:(UIView *)view;
-(void)setHomeCameraNavigations:(UIViewController *)vc;
-(void)setBackNavigations:(UIViewController *)vc;
-(void)setDDmenuTitleNavigations:(UIViewController *)vc;

@property (nonatomic, retain) LoadingView *loadingView;
- (void)navBarSlideLeft:(BOOL)isLeft;
-(void)setBackMenuNavigations:(UIViewController *)vc;

@end
