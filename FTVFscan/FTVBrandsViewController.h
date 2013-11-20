//
//  FTVBrandsViewController.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTVBrandsViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *brandsWebView;

-(IBAction)OpenMenu:(id)sender;
@end
