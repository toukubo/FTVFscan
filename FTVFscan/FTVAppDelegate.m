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

#import "MSNavigationPaneViewController.h"
#import "SVLeftMenuViewController.h"
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
    if ([self checkLoginCredential]) {
        // goto home tab bar controller
        [self switchSceneToTabController];
        DLog(@"but true");
    } else {
        [self switchSceneToTabController];

//        [self switchSceneToRegisterController];
        DLog(@"but false. going to regist ");
    }
    
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
    UIViewController *controller = [mvc.storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:nav];
    _menuController = rootController;
	
    
    UIViewController *controllerRight = [mvc.storyboard instantiateViewControllerWithIdentifier:@"FTVMenuViewController"];
    rootController.rightViewController = controllerRight;
    
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
}


-(void)setViewFromMenu:(NSString *)storyBoardId
{
//    UIViewController *mvc = (UIViewController *)self.window.rootViewController;
//    UIViewController *controller = [mvc.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    [self.navigationPaneViewController setPaneViewController:controller];
    [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
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
//    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block BOOL retval = NO;
    
    NSMutableURLRequest* request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
	[request2 setHTTPMethod:@"GET"];
	//リクエストしてデータを取得
	
	NSURLResponse *response;
	NSError *error;
	NSData *dataReplay = [NSURLConnection sendSynchronousRequest:request2
									   returningResponse:&response error:&error];
	NSString *receivedString = [[NSString alloc] initWithData:dataReplay encoding:NSUTF8StringEncoding];
	DLog(@"%@", receivedString);
    if ([receivedString isEqualToString:@"true"]) {
        retval = YES;
    } else {
        retval = NO;
    }

    
    
    
    /**
    
    
    
    
    [request setStartedBlock:^{
        [SVProgressHUD show];
    }];
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        
        NSString *resp = [request responseString];
        DLog(resp);
        UIAlertView *alert2 =
        [[UIAlertView alloc] initWithTitle:@"debug" message:resp
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert2 show];
        if ([resp isEqualToString:@"true"]) {
            retval = YES;
        } else {
            retval = NO;
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        retval = NO;
        UIAlertView *alert4 =
        [[UIAlertView alloc] initWithTitle:@"netowork fail" message:@"network接続に失敗しました。"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert4 show];

    }];
    
    // wait on registraton validation
    [request startSynchronous];
    UIAlertView *alert3 =
    [[UIAlertView alloc] initWithTitle:@"debug" message:@"check ending"
                              delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
    [alert3 show];
*/
    
    //TODO: simple change retval to NO to quick test register process
//    return YES;
    return retval;
}

/**
 * Utility Function, invoked by Camera/Gallery controller
 */
- (void)showModalPopupWindow
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 310)];
    FTVDelayJobWebViewController *vc = [[FTVDelayJobWebViewController alloc] initWithFrame:contentView.frame];
    NSString *url = [NSString stringWithFormat:@"%@%@", BASEURL, @"search"];
    [contentView addSubview:vc.view];
    
    [vc loadUrl:url];
    
    [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
    [self.window.rootViewController addChildViewController:vc];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

@end
