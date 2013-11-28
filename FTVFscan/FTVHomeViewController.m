//
//  FTVHomeViewController.m
//  FTVFscan
//
//  Created by Ganapathi Rallapalli on 22/11/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVHomeViewController.h"
#import "RegexKitLite.h"

@interface FTVHomeViewController ()
@end

@implementation FTVHomeViewController
@synthesize redirectUrl;
@synthesize homePageWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
