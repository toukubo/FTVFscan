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


@interface FTVTourViewController ()

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

@end
