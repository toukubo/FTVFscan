//
//  FTVDelayJobWebViewController.h
//  FTVFscan
//
//  Created by Alsor Zhou on 13-11-6.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTVCustomNavigationController.h"

@interface FTVDelayJobWebViewController : FTVCustomNavigationController<UIWebViewDelegate>

@property (nonatomic, retain) NSString *redirectUrl;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIView *statusBackground;
@property (nonatomic, retain) UIActivityIndicatorView *busyIndicator;

- (IBAction)dismissModalView:(id)sender;

- (id)initWithFrame:(CGRect)frame;
- (void)loadUrl:(NSString*)url;
@end
