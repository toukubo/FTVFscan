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

@implementation FTVAppDelegate

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
        [self switchSceneToRegisterController];
        DLog(@"but false. going to regist ");
    }
    
    // set selected tab image tint color, dont use setTintColor directly, which will make whole bar to be rendered
    [[UITabBar appearance] setSelectedImageTintColor:[ColorUtil colorWithHexString:@"FF0080"]];
    
    if ([[UINavigationBar appearance] respondsToSelector:@selector(setBarTintColor:)]) {
        /*
         The behavior of tintColor for bars has changed on iOS 7.0. It no longer affects the bar's background
         and behaves as described for the tintColor property added to UIView.
         To tint the bar's background, please use -barTintColor.
         */
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    } else {
        /*
         * ios 5 - 6
         */
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    }
    
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
    UITabBarController *controller = [mvc.storyboard instantiateViewControllerWithIdentifier:@"ftvTabController"];
    controller.selectedIndex = 2;
    
    // programly set the tab bar item title
    ((UITabBarItem *)controller.tabBar.items[0]).title = NSLocalizedString(@"tabbar_item_title_tour", @"Tour");
    ((UITabBarItem *)controller.tabBar.items[1]).title = NSLocalizedString(@"tabbar_item_title_history", @"History");
    ((UITabBarItem *)controller.tabBar.items[2]).title = NSLocalizedString(@"tabbar_item_title_ftvscan", @"FTVFscan");
    ((UITabBarItem *)controller.tabBar.items[3]).title = NSLocalizedString(@"tabbar_item_title_gallery", @"Gallery");
    ((UITabBarItem *)controller.tabBar.items[4]).title = NSLocalizedString(@"tabbar_item_title_brands", @"Brands");
    
    [self.window setRootViewController:controller];
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
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", BASEURL, @"/registration/isRegistered.php?deviceid=", [FTVUser getId]];
    DLog(urlStr);
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block BOOL retval = NO;
    
    [request setStartedBlock:^{
        [SVProgressHUD show];
    }];
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        
        NSString *resp = [request responseString];
        DLog(resp);
        if ([resp isEqualToString:@"true"]) {
            retval = YES;
        } else {
            retval = NO;
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        retval = NO;
    }];
    
    // wait on registraton validation
    [request startSynchronous];
    
    //TODO: simple change retval to NO to quick test register process
    return YES;
//    return retval;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
