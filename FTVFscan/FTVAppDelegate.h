//
//  FTVAppDelegate.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSNavigationPaneViewController;
@class DDMenuController;

@interface FTVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSNavigationPaneViewController *navigationPaneViewController;
@property (strong, nonatomic) DDMenuController *menuController;


- (void)showModalPopupWindow;
-(void)setViewFromMenu:(NSString *)storyBoardId;
- (void)switchSceneToTabController;
@end
