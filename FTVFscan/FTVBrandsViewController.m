//
//  FTVBrandsViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVBrandsViewController.h"

#import "RegexKitLite.h"


@interface FTVBrandsViewController ()
{
    BOOL isGoBack;
}

@end

@implementation FTVBrandsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _brandsWebView.delegate = self;
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
    [super setHomeCameraMenuNavigations:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    _brandsWebView.delegate = self;
    [_brandsWebView setScalesPageToFit:YES];
    [_brandsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [ BASEURL stringByAppendingString:@"brands"]]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonClick:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
}


#pragma --
#pragma webview delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
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

-(void)doneButtonClick:(NSNotification*)aNotification
{
    //Do whatever you want here
    if ([_brandsWebView canGoBack]) {
        [_brandsWebView goBack];
        isGoBack = YES;
    }
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
