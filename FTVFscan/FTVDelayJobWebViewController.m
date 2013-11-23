//
//  FTVDelayJobWebViewController.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-11-6.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import "FTVDelayJobWebViewController.h"

#import "RegexKitLite.h"

@interface FTVDelayJobWebViewController ()

@end

@implementation FTVDelayJobWebViewController
@synthesize redirectUrl;
@synthesize webView;

/**
 * This function only invoked from FTVAppDelegate - showModalPopupWindow
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        CGRect rect = CGRectMake(0, -20, frame.size.width, frame.size.height);
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        }
        
        // If this controller was init from FTVAppDelegate - showModalPopupWindow,
        // the webview is not initialized
        self.webView = [[UIWebView alloc] initWithFrame:rect];
        
        self.view.frame = rect;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.webView setDelegate:self];
    
    self.navigationController.navigationBarHidden = NO;
    self.webView.scalesPageToFit = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 45, 45)];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    if (redirectUrl != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:redirectUrl]];

        [self.webView loadRequest:request];
    }
    
    if ([[self.view subviews] count] == 0) {
        // If this controller was init from FTVAppDelegate - showModalPopupWindow,
        // the webview is not added to view
        [self.view addSubview:self.webView];
    }
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)back
{
    if([self.webView canGoBack])
    {
        [self.webView goBack];
    }
}
    

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadUrl:(NSString*)url
{
    if (!IsEmpty(url)) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        [self.webView loadRequest:request];
    }
}
#pragma mark - UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
//    DLog(@"%@", urlString);
    if ([self needOpenExternalSafari:urlString]) {
        [FTVImageProcEngine openSafari:urlString];
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"hud_error_network_failed", @"Failed")];
}

- (void)viewDidUnload
{
    [self removeFromParentViewController];
    
    [super viewDidUnload];
}

#pragma mark - Helper
- (IBAction)dismissModalView:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)needOpenExternalSafari:(NSString*)url
{
    if ([url isMatchedByRegex:@"target=_blank"]) {
        return YES;
    }
    
    return NO;
}
@end
