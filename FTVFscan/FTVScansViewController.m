//
//  FTVSecondViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVScansViewController.h"

#import "RegexKitLite.h"


@interface FTVScansViewController ()
{
    BOOL isGoBack;
}

@end

@implementation FTVScansViewController

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
    _scansWebView.delegate = self;
    
    [super setHomeCameraMenuNavigations:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *req_url = [NSString stringWithFormat:@"%@%@%@", BASEURL,@"/scan/list.php?deviceid=",[FTVUser getId]];
    DLog(req_url);

    [_scansWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:req_url]]];
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
