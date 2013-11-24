//
//  FTVHomeViewController.h
//  FTVFscan
//
//  Created by Ganapathi Rallapalli on 22/11/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTVCustomNavigationController.h"

@interface FTVHomeViewController : FTVCustomNavigationController<UIWebViewDelegate>
@property (nonatomic, retain) NSString *redirectUrl;

@end
