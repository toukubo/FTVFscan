//
//  FTVFirstViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVTourViewController.h"
#import "FTVAppDelegate.h"

#import "RegexKitLite.h"
#import "MSNavigationPaneViewController.h"
#import "DDMenuController.h"


@interface FTVTourViewController ()
{
    BOOL isGoBack;
}

@end

@implementation FTVTourViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
//    appDelegate = (FTVAppDelegate *)[UIApplication sharedApplication].delegate);
    
    _tourWebView.delegate = self;
    self.navigationController.navigationBarHidden = NO;
    _tourWebView.scalesPageToFit = NO;
    _tourWebView.multipleTouchEnabled = NO;
    
    for (id subview in _tourWebView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    
    [super setHomeCameraMenuNavigations:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *url =  [BASEURL stringByAppendingString: @"tour"];

    [_tourWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma --
#pragma webView delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    DLog(@"%@", urlString);
    if ([self needOpenExternalSafari:urlString]) {
        [FTVImageProcEngine openSafari:urlString];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [self navBarSlideLeft:!isGoBack];
    [self statusIndicatorShow];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self statusIndicatorHide];
    isGoBack = NO;
}

- (void)statusIndicatorShow
{
    [self.loadingView show];
}

- (void)statusIndicatorHide
{
    [self.loadingView hide];
}



- (BOOL)needOpenExternalSafari:(NSString*)url
{
    if ([url isMatchedByRegex:@"target=_blank"]) {
        return YES;
    }
    
    return NO;
}


-(IBAction)OpenMenu:(id)sender
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRightController:YES];

}
@end
