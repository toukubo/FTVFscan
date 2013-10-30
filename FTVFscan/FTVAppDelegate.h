//
//  FTVAppDelegate.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Making pickers there cos is damn init
@property (strong, nonatomic) UIImagePickerController *photoPicker;
@property (strong, nonatomic) UIImagePickerController *galleryPicker;


@end
