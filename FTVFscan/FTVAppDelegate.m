//
//  FTVAppDelegate.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVAppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "FTVUser.h"

#import "FTVDelayJobWebViewController.h"
#import "DDMenuController.h"


@implementation FTVAppDelegate

@synthesize menuController = _menuController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // TODO: ------------------- other application launch stuff -------------------
    
    // TODO: Flurry
    
    // TODO: Testflight
    
    // TODO: Appirater
    
    // TODO: advertise SDK
    
    // Check credential
//    sleep(2);

    [self switchSceneToTabController];
    
    application.statusBarHidden = YES;
    
    // set selected tab image tint color, dont use setTintColor directly, which will make whole bar to be rendered
    //    [[UITabBar appearance] setSelectedImageTintColor:[ColorUtil colorWithHexString:@"FF0080"]];
    //
    //    // http://stackoverflow.com/a/19029973
    //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
    //        /*
    //         The behavior of tintColor for bars has changed on iOS 7.0. It no longer affects the bar's background
    //         and behaves as described for the tintColor property added to UIView.
    //         To tint the bar's background, please use -barTintColor.
    //         */
    //        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    //        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //    } else {
    //        /*
    //         * ios 5 - 6
    //         */
    //        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    //    }
    
    return YES;
}

- (void)switchSceneToRegisterController
{
    UIViewController *mvc = (UIViewController *)self.window.rootViewController;
    UIViewController *controller = [mvc.storyboard instantiateViewControllerWithIdentifier:@"ftvNavRegisterViewController"];
    [self.window setRootViewController:controller];
    
    __block id complete;
    
    complete = [[NSNotificationCenter defaultCenter] addObserverForName:kNotifyRegisterFinished
                                                                 object:controller
                                                                  queue:nil
                                                             usingBlock:^(NSNotification *note) {
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:complete];
                                                                 
                                                                 [self switchSceneToTabController];
                                                                 
                                                                 //gonna do re-checking if the regisration is completed. if not ,eternal loop.
                                                                 if ([self checkLoginCredential]) {
                                                                     // goto home tab bar controller
                                                                     [self switchSceneToTabController];
                                                                     DLog(@"but true");
                                                                 } else {
                                                                     [self switchSceneToRegisterController];
                                                                     DLog(@"but false. going to regist ");
                                                                 }
                                                             }];
}
/**
 * Change window root controller to Tab bar controller
 */
- (void)switchSceneToTabController
{
    UIViewController *mvc = (UIViewController *)self.window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];

    FTVDelayJobWebViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FTVDelayJobWebViewController"];

    controller.redirectUrl = CONTENTBASE;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:controller];
    _menuController = rootController;
	
    
    UIViewController *controllerRight = [mvc.storyboard instantiateViewControllerWithIdentifier:@"FTVMenuViewController"];
    _menuController.rightViewController = controllerRight;
    
    self.window.rootViewController = _menuController;
    [self.window makeKeyAndVisible];
}

- (void)switchSceneToCameraController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];

    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:controller];
    _menuController = rootController;
	
    
    UIViewController *controllerRight = [storyboard instantiateViewControllerWithIdentifier:@"FTVMenuViewController"];
    _menuController.rightViewController = controllerRight;
    
    
    self.window.rootViewController = _menuController;
    [self.window makeKeyAndVisible];
}

-(void)setViewFromMenu:(NSString *)storyBoardId
{
    //    UIViewController *mvc = (UIViewController *)self.window.rootViewController;
    //    UIViewController *controller = [mvc.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
    //    [self.navigationPaneViewController setPaneViewController:controller];
    //    [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Helper
- (BOOL)checkLoginCredential {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", BASEURL, @"registration/isRegistered.php?deviceid=", [FTVUser getId]];
    DLog(@"%@", urlStr);
    
    __block BOOL retval = NO;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
	[request setHTTPMethod:@"GET"];
	//リクエストしてデータを取得
	
	NSURLResponse *response;
	NSError *error;
	NSData *dataReplay = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response error:&error];
	NSString *receivedString = [[NSString alloc] initWithData:dataReplay encoding:NSUTF8StringEncoding];
	DLog(@"%@", receivedString);
    if ([receivedString isEqualToString:@"true"]) {
        retval = YES;
    } else {
        retval = NO;
    }
    //TODO: simple change retval to NO to quick test register process
    return retval;
}

/**
 * Utility Function, invoked by Camera/Gallery controller
 */
- (void)showModalPopupWindow
{
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 310)];
//    FTVDelayJobWebViewController *vc = [[FTVDelayJobWebViewController alloc] initWithFrame:contentView.frame];
    NSString *url = [NSString stringWithFormat:@"%@%@", BASEURL, @"search"];
//    [contentView addSubview:vc.view];
    
//    [vc loadUrl:url];
    
//    [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
//    [self.window.rootViewController addChildViewController:vc];
    
//    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
//    [menuController setRootViewController:vc];
//    [menuController showRootController:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    FTVDelayJobWebViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FTVDelayJobWebViewController"];
    controller.redirectUrl = url;
    controller.ShowResultPage = YES;
    
    [menuController setRootController:controller animated:YES];
    [menuController showRootController:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

@end
