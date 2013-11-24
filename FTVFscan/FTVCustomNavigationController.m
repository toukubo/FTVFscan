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
    
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [homeButton setImage:[UIImage imageNamed:@"home_white.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
    [    self.view addSubview:homeButton];
    

    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 10, 20, 20)];
    [cameraButton setImage:[UIImage imageNamed:@"camera_white.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [    self.view addSubview:cameraButton];
    
    
    
    
	// Do any additional setup after loading the view.
}


- (void)cameraAction
{
    [self cameraAction:self];
}

- (void)homeAction
{
    [self homeAction:self];
}



-(IBAction)homeAction:(id)sender{
    FTVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate switchSceneToTabController];

//    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
//    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVHomeViewController"];
//    [menuController setRootController:controller animated:YES];
}

-(IBAction)OpenMenu:(id)sender
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRightController:YES];
    
}


-(IBAction)cameraAction:(id)sender{
    FTVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate switchSceneToCameraController];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
