//
//  FTVFirstViewController.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTVCustomNavigationController.h"

@interface FTVTourViewController : FTVCustomNavigationController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *tourWebView;

-(IBAction)OpenMenu:(id)sender;
@end
