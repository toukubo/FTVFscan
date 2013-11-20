//
//  SVWebViewController.h
//  SVIPad
//
//  Created by Tim Tretyak on 24.02.13.
//  Copyright (c) 2013 studiovoice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVWebViewController : UIViewController <UIWebViewDelegate>

@property (strong,nonatomic) UIWebView *webView;
@property (strong,nonatomic) UIActivityIndicatorView *busyIndicator;

@end
