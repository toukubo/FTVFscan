//
//  FTVHomeViewController.m
//  FTVFscan
//
//  Created by Sarkar Raj on 11/23/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVHomeViewController.h"

#import "RegexKitLite.h"

@interface FTVHomeViewController ()

@end

@implementation FTVHomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;

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
}


- (void)viewWillAppear:(BOOL)animated
{
    homeWebView.delegate = self;
    [homeWebView setScalesPageToFit:YES];
    [homeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://zxc.cz/fdb/"]]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonClick:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }else if ([self needOpenScanCameraPage:urlString]) {
        DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];
        [menuController setRootViewController:controller];
        [menuController showRootController:YES];
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


-(BOOL)needOpenScanCameraPage:(NSString *)url
{
    if ([url isMatchedByRegex:@"http://zxc.cz/fdb/category/brands/"]) {
        NSLog(@"Link Found");
        return YES;
    }
    
    return NO;
}

@end
