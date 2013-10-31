//
//  FTVSecondViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVScansViewController.h"

@interface FTVScansViewController ()

@end

@implementation FTVScansViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _scansWebView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *req_url = [NSString stringWithFormat:@"%@%@%@", BASEURL,@"/scans/index.php?deviceid=",[FTVUser getId]];
    DLog(req_url);

    [_scansWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:req_url]]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
