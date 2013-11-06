//
//  FTVRegisterViewController.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-10-29.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import "FTVRegisterViewController.h"

static NSString * const URL_REGISTRTION = @"/registration/index.php";

@interface FTVRegisterViewController ()

@end

@implementation FTVRegisterViewController

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
    
    NSString *req_url = [NSString stringWithFormat:@"%@%@%@%@", URL_REGISTRTION,@"?deviceid=",[FTVUser getId],@"&device_type=iphone"];
    DLog(req_url);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASEURL, req_url]];
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


- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
