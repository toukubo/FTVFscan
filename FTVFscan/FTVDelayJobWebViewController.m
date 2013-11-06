//
//  FTVDelayJobWebViewController.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-11-6.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import "FTVDelayJobWebViewController.h"

#import "RegexKitLite.h"

@interface FTVDelayJobWebViewController () <UIWebViewDelegate>

@end

@implementation FTVDelayJobWebViewController
@synthesize redirectUrl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (redirectUrl != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:redirectUrl]];
        
        [self.webView setDelegate:self];
        [self.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    DLog(@"%@", urlString);
    if ([self needOpenExternalSafari:urlString]) {
        [FTVImageProcEngine openSafari:urlString];
    }
    
    return YES;
}


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
