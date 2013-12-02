//
//  FTVBrandsViewController.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTVCustomNavigationController.h"
#import "FTVDelayJobWebViewController.h"


@interface FTVBrandsViewController : FTVDelayJobWebViewController

@property (strong, nonatomic) IBOutlet UIWebView *brandsWebView;

-(IBAction)OpenMenu:(id)sender;
@end
