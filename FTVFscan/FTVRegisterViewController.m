//
//  FTVRegisterViewController.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-10-29.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import "FTVRegisterViewController.h"

static NSString * const URL_REGISTRTION = @"/registration";

@interface FTVRegisterViewController ()

@end

@implementation FTVRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, URL_REGISTRTION]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)dismissModalController:(id)sender {
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyRegisterFinished object:self.navigationController userInfo:nil];
//    }];
}
@end
