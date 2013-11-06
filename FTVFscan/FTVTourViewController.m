//
//  FTVFirstViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVTourViewController.h"
#import "FTVAppDelegate.h"


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

@end
