//
//  FTVCustomNavigationController.m
//  FTVFscan
//
//  Created by Ganapathi Rallapalli on 22/11/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVCustomNavigationController.h"
#import "FTVHomeViewController.h"
#import "FTVCameraViewController.h"
#import "FTVDelayJobWebViewController.h"


@interface FTVCustomNavigationController (){
    NSString                    *redirectUrl;
    UIView  *navigationBar;
}

@end

@implementation FTVCustomNavigationController
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
    
    self.loadingView = [[LoadingView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.loadingView];
    
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;

    
//do it in programing code
//    maybe a black bar and buttons as subview on it.
    
//    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
//    [homeButton setImage:[UIImage imageNamed:@"home_white.png"] forState:UIControlStateNormal];
//    [homeButton addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
//    [    self.view addSubview:homeButton];
//    
//
//    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 10, 20, 20)];
//    [cameraButton setImage:[UIImage imageNamed:@"camera_white.png"] forState:UIControlStateNormal];
//    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
//    [    self.view addSubview:cameraButton];
    
    
    
    
	// Do any additional setup after loading the view.
}

-(void)setBackButton:(UIView *)view vc:(UIViewController *)vc{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [backButton addTarget:vc action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:backButton];
}

-(void)setMenuButton:(UIView *)view{
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 40, 2, 40, 40)];
    [menuButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [menuButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:menuButton];
}


-(void)setCameraButton:(UIView *)view{
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 44, 44)];
    [cameraButton setImage:[UIImage imageNamed:@"camera_white.png"] forState:UIControlStateNormal];
    [cameraButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cameraButton];
}

-(void)setFirstCameraButton:(UIView *)view{
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [cameraButton setImage:[UIImage imageNamed:@"camera_white.png"] forState:UIControlStateNormal];
    [cameraButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cameraButton];
}


-(void)setHomeButton:(UIView *)view{
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [homeButton setImage:[UIImage imageNamed:@"home_white.png"] forState:UIControlStateNormal];
    [homeButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [homeButton addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:homeButton];
}
-(void)drawTitle:(UIView *)view{
    UIImage *titleImage = [UIImage imageNamed:@"240head.png"];
    int imageWidth = titleImage.size.width;
    int imageHeight = titleImage.size.height;
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth/2 - 50), 13, 100, 16)];//(100, 12, 127, 20)
    titleView.image = titleImage;
    [view addSubview:titleView];
}

- (void)navBarSlideLeft1:(CGRect)refRect
{
    [UIView beginAnimations:@"NavBarLeft" context:nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration:0.5];
	refRect = CGRectMake(-320, 0, 320, 50);
    [navigationBar setFrame:refRect];
	[UIView commitAnimations];
    
    
//    UIView *superView = navigationBar.superview;
//    [navigationBar removeFromSuperview];
//    [navigationBar setFrame:CGRectMake(320, 0, 320, 50)];
//    [superView addSubview:navigationBar];
//    double delayInSeconds = 0.5;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [UIView beginAnimations:@"NavBarLeft" context:nil];
//        [UIView setAnimationBeginsFromCurrentState: YES];
//        [UIView setAnimationDuration:0.5];
//        CGRect refRect = CGRectMake(0, 0, 320, 50);
//        [navigationBar setFrame:refRect];
//        [UIView commitAnimations];
//    });
    
}

- (void)navBarSlideLeft:(BOOL)isLeft
{
    CGRect rect = navigationBar.superview.frame;
    
    UIView *fakeView =  [NSKeyedUnarchiver unarchiveObjectWithData:
             [NSKeyedArchiver archivedDataWithRootObject:navigationBar.superview]];
    if (isLeft) {
        [navigationBar.superview setFrame:CGRectMake(320, 0, 320, rect.size.height)];
    }
    else
    {
        [navigationBar.superview setFrame:CGRectMake(-320, 0, 320, rect.size.height)];
    }
    
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView beginAnimations:@"NavBarLeft" context:nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration:0.5];
        if (isLeft) {
            [fakeView setFrame:CGRectMake(-320, 0, 320, rect.size.height)];
        }
        else
        {
            [fakeView setFrame:CGRectMake(320, 0, 320, rect.size.height)];
        }
        [navigationBar.superview setFrame:CGRectMake(0, 0, 320, rect.size.height)];
        [UIView commitAnimations];
    });
}


-(UIView*)drawBackground{
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    navigationView.backgroundColor = [UIColor blackColor];
    [self drawTitle:navigationView  ];
    navigationBar = navigationView;
    return navigationView;

}

// Custom Method For DDMenu Background
-(UIView*)drawBackgroundDDMenu{
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    navigationView.backgroundColor = [UIColor blackColor];
    navigationBar = navigationView;
    return navigationView;
}


-(void)setHomeCameraMenuNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setHomeButton:navigationView];
    [self setCameraButton:navigationView];
    [self setMenuButton:navigationView];
    [vc.view addSubview:navigationView];
}

-(void)setCameraMenuNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setFirstCameraButton:navigationView];
    [self setMenuButton:navigationView];
    [vc.view addSubview:navigationView];
}

-(void)setHomeMenuNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setHomeButton:navigationView];
    [self setMenuButton:navigationView];
    [vc.view addSubview:navigationView];
}

-(void)setHomeCameraNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setHomeButton:navigationView];
    [self setCameraButton:navigationView];
    [vc.view addSubview:navigationView];
}

-(void)setBackCameraMenuNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setHomeButton:navigationView];
    [self setCameraButton:navigationView];
    [self setMenuButton:navigationView];
    [self setBackButton:navigationView vc:vc];
    [vc.view addSubview:navigationView];
}

-(void)setBackCameraNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setCameraButton:navigationView];
    [self setBackButton:navigationView vc:vc];
    [vc.view addSubview:navigationView];
}


-(void)setBackMenuNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setMenuButton:navigationView];
    [self setBackButton:navigationView vc:vc];
    [vc.view addSubview:navigationView];
}

-(void)setBackNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
//    [self setCameraButton:navigationView];
    [self setBackButton:navigationView vc:vc];
    [vc.view addSubview:navigationView];
}


// Custome Navigation Bar For the DDMenu
-(void)setDDmenuTitleNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackgroundDDMenu];
    UIImage *titleImage = [UIImage imageNamed:@"240head.png"];
    UIImageView *titleView;
    
    for (UIView *subView in vc.view.subviews) {
        if ([subView isKindOfClass:[UITableView class]]) {
            UITableView *menuTableView = (UITableView *)subView;
            CGRect Newframe = menuTableView.frame;
            NSLog(@"FOund The tabel Frame: %f", Newframe.origin.x);
            titleView = [[UIImageView alloc] initWithFrame:CGRectMake((Newframe.origin.x + Newframe.size.width/2 - 50), 13, 100, 16)];
        }
    }
    
    titleView.image = titleImage;
    [navigationView addSubview:titleView];
    [vc.view addSubview:navigationView];
}


-(void)setTitleNavigation:(UIViewController *)vc{
    //Title
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 13, 100, 16)];
    titleView.image = [UIImage imageNamed:@"240head.png"];
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    navigationView.backgroundColor = [UIColor blackColor];
    [navigationView addSubview:titleView];
    [vc.view addSubview:navigationView];
}


-(void)backAction
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRootController:YES];
}

-(void)homeAction{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    
    FTVDelayJobWebViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FTVDelayJobWebViewController"];
    controller.redirectUrl = CONTENTBASE;
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController setRootController:controller animated:YES];
    [menuController showRootController:YES];

    
}

-(void)openMenu
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRightController:YES];
}


-(void)cameraAction{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    
    FTVDelayJobWebViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController setRootController:controller animated:YES];
    [menuController showRootController:YES];

    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
