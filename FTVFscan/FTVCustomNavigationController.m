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

@interface FTVCustomNavigationController (){
    NSString                    *redirectUrl;
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

-(void)setBackButton:(UIView *)view :(UIViewController *)vc{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backButton addTarget:vc action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:backButton];
}

-(void)setMenuButton:(UIView *)view{
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(290, 10, 30, 30)];
    [menuButton setImage:[UIImage imageNamed:@"draw_white.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:menuButton];
}


-(void)setCameraButton:(UIView *)view{
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, 30, 30)];
    [cameraButton setImage:[UIImage imageNamed:@"camera_white.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cameraButton];
}


-(void)setHomeButton:(UIView *)view{
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    [homeButton setImage:[UIImage imageNamed:@"home_white.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:homeButton];
}
-(void)drawTitle:(UIView *)view{
    
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 104, 17)];
    titleView.image = [UIImage imageNamed:@"ftvlogo.png"];
    [view addSubview:titleView];

}

-(UIView*)drawBackground{
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    navigationView.backgroundColor = [UIColor blackColor];
    return navigationView;

}
-(void)setHomeCameraMenuNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setHomeButton:navigationView];
    [self setCameraButton:navigationView];
    [self setMenuButton:navigationView];
    [vc.view addSubview:navigationView];
}

-(void)setHomeMenuNavigations:(UIViewController *)vc{
    //Left Navigation Items
    UIView *navigationView = [self drawBackground];
    [self setHomeButton:navigationView];
//    [self setCameraButton:navigationView];
    [self setMenuButton:navigationView];
    [vc.view addSubview:navigationView];

    
}

-(void)setBackCameraMenuNavigations:(UIViewController *)vc{
    UIView *navigationView = [self drawBackground];
    [self setHomeButton:navigationView];
    [self setCameraButton:navigationView];
    [self setMenuButton:navigationView];
    [self setBackButton:navigationView :vc];

    [vc.view addSubview:navigationView];

    
}

-(void)setTitleNavigation:(UIViewController *)vc{
    //Title
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 100, 25)];
    titleView.image = [UIImage imageNamed:@"drawer-head-logo.png"];
    
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    navigationView.backgroundColor = [UIColor blackColor];
    [navigationView addSubview:titleView];
    [vc.view addSubview:navigationView];
}


-(void)homeAction{
    FTVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate switchSceneToTabController];
}

-(void)openMenu
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRightController:YES];
    
}


-(void)cameraAction{
    FTVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate switchSceneToCameraController];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
