//
//  FTVDelayJobWebViewController.h
//  FTVFscan
//
//  Created by Alsor Zhou on 13-11-6.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTVDelayJobWebViewController : UIViewController

@property (nonatomic, retain) NSString *redirectUrl;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)dismissModalView:(id)sender;


@end
