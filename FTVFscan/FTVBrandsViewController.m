//
//  FTVBrandsViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVBrandsViewController.h"

@interface FTVBrandsViewController ()

@end

@implementation FTVBrandsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _brandsWebView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_brandsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [ BASEURL stringByAppendingString:@"brands"]]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end