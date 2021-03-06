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
{
    BOOL isGoBack;
    BOOL skipUrl;
    int count;
    NSMutableArray *urlHolderArray;
}

@end

@implementation FTVDelayJobWebViewController
@synthesize ShowResultPage;
@synthesize redirectUrl;
@synthesize webView;

/**
 * This function only invoked from FTVAppDelegate - showModalPopupWindow
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        CGRect rect = CGRectMake(0, 30, frame.size.width, frame.size.height);
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            rect = CGRectMake(0, 50, frame.size.width, frame.size.height);
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
    NSLog(@"VDL,,,");
    count = 0;
    skipUrl = NO;
    urlHolderArray = [[NSMutableArray alloc] init];
    
    [self.webView setDelegate:self];
    self.navigationController.navigationBarHidden = YES;
    self.webView.autoresizesSubviews = YES;
    self.webView.scalesPageToFit = NO;
    self.webView.multipleTouchEnabled = NO;
    
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setFrame:CGRectMake(0, 0, 45, 45)];
//    [backButton setTitle:@"back" forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
  
//    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [homeButton setImage:[UIImage imageNamed:@"home_white.png"] forState:UIControlStateNormal];
//    [homeButton addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *leftItem1 = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
//    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [cameraButton setImage:[UIImage imageNamed:@"camera_white.png"] forState:UIControlStateNormal];
//    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *leftItem2 = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
//    NSArray *actionButtonItems = @[leftItem1, leftItem2];
//    self.navigationItem.leftBarButtonItems = actionButtonItems;
//    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];

//    [self setBackCameraMenuNavigations:self];
    
    if (redirectUrl != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:redirectUrl]];

        [self.webView loadRequest:request];
    }
    
    if ([[self.view subviews] count] == 0) {
        // If this controller was init from FTVAppDelegate - showModalPopupWindow,
        // the webview is not added to view
        [self.view addSubview:self.webView];
    }else{
        NSLog(@"initial load...");
    }
    
//    [super setHomeCameraMenuNavigations:self];

    
    
}
//- (void)openMenu
//{
//    [super openMenu];
//}
//
//- (void)cameraAction
//{
//    [super cameraAction];
//}
//
//- (void)homeAction
//{
//    [super homeAction];
//}


- (void)backAction
{
    NSLog(@"back...");
    if([self.webView canGoBack])
    {
        isGoBack = YES;
        
        int counter = [urlHolderArray count];
        for (int i = 0; i < counter; i++) {
            NSString *urlString = [urlHolderArray lastObject];
            if([urlString hasPrefix:@"http://www.youtube.com/embed"]) {
                [urlHolderArray removeLastObject];
                
                NSString *urlString = [urlHolderArray lastObject];
                if([urlString hasPrefix:@"http://fscan.fashiontv.co.jp/fdbdev/brandlogo_"]) {
                    [urlHolderArray removeLastObject];
                    skipUrl = YES;
                    break;
                }

            }
        }
        
        if (skipUrl) {
            NSString *url = [urlHolderArray lastObject];
            [self loadUrl:url];
            skipUrl = NO;
        }else {
            [urlHolderArray removeLastObject];
            [self.webView goBack];
        }
        
    }
    
    NSLog(@"%@", urlHolderArray);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadUrl:(NSString*)url
{
    NSLog(@"loadUrl...%@", url);
   

    if (!IsEmpty(url)) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
    }
}
#pragma mark - UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    NSLog(@"webViewDidStartLoad,,,");
    [self statusIndicatorShow];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSLog(@"webViewDidFinishLoad,,,");
    [self statusIndicatorHide];
    if (ShowResultPage) {
//        [super setHomeCameraMenuNavigations:self];
    }
    isGoBack = NO;
    
    for (id subview in self.webView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
}

- (void)statusIndicatorShow
{
    [self.loadingView show];
}

- (void)statusIndicatorHide
{
    [self.loadingView hide];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    NSLog(@"shouldStartLoadWithRequest,,,");
    NSString *urlString = request.URL.absoluteString;
//    DLog(@"%@", urlString);
//    if ([self needOpenExternalSafari:urlString]) {
//        [FTVImageProcEngine openSafari:urlString];
//        return NO;
//    }
//    
//    return YES;
    
    return ![self shouldOverrideUrlLoading:urlString];
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
    
//    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)needOpenExternalSafari:(NSString*)url
{
    if ([url isMatchedByRegex:@"target=_blank"]) {
        return YES;
    }
    
    return NO;
}

//-(void)setNavigationItems:(NSString *)urlString{
//    if ([urlString isEqualToString:@"http://zxc.cz/fdbdev/"]) {
//        [super setCameraMenuNavigations:self];
//    }else if ([urlString isEqualToString:@"http://zxc.cz/fdbdev/category/news/"]) {
//        [super setHomeCameraMenuNavigations:self];
//    }else if ([urlString isEqualToString:@"http://zxc.cz/fdbdev/category/theater/"]) {
//        [super setHomeCameraMenuNavigations:self];
//    }else if ([urlString isEqualToString:@"http://zxc.cz/fdbdev/category/topic/"]) {
//        [super setHomeCameraMenuNavigations:self];
//    }else {
//        [super setBackCameraNavigations:self];
//    }
//}

- (BOOL)shouldOverrideUrlLoading:(NSString *)urlString
{
    NSLog(@"%@", urlString);
    NSLog(@"Count : %d", count);
    count += 1;
    [urlHolderArray addObject:urlString];
    
//    if([urlString hasPrefix:@"http://fscan.fashiontv.co.jp/fdbdev/category/brands"]){
//        [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"last_url"];
//        skipUrl = NO;
//    }else if([urlString hasPrefix:@"http://www.youtube.com/embed"]) {
//        skipUrl = YES;
//    }

    if ([self needOpenExternalSafari:urlString]) {
        [FTVImageProcEngine openSafari:urlString];
        return YES;
    }
    else if ([urlString hasPrefix:@"inapp-http"]) {
        NSString *uri = [urlString stringByReplacingOccurrencesOfString:@"inapp-http://" withString:@""];
        if ([uri hasPrefix:@"local/"]) {
            uri = [uri stringByReplacingOccurrencesOfString:@"local/" withString:@""];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"file:///android_asset/" ofType:@"*"] isDirectory:NO]]];
        }
        else
        {
            /** @TODO this code, is NOT tested and being commited. */
            if([urlString rangeOfString:@"scan/list.php"].location != NSNotFound)
            {
                // Todo by gailya, what's the device id;
                [self loadUrl:[NSString stringWithFormat:@"http://%@?deviceid=%d", uri, 999]];
            }
            else
            {
                [self loadUrl:[NSString stringWithFormat:@"http://%@", uri]];
            }
        }
        return YES;
    }
    else if([urlString hasSuffix:@".action"])
    {
        NSString *action = [urlString stringByReplacingOccurrencesOfString:@".action" withString:@""];
        
        // Todo: gailya need to confirm the way to load the camera/gallery with drawer
        if ([action hasSuffix:@"Camera"]) {

            DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];
            [menuController setRootController:controller animated:YES];
            [menuController showRootController:YES];

            
        }
        else if([action hasSuffix:@"Gallery"])
        {
            DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVGalleryViewController"];
            [menuController setRootController:controller animated:YES];
            [super setHomeCameraMenuNavigations:self];
        }
        
        return YES;
    }else {
        //////////// these are for home/back button switching.
        self.webView.scalesPageToFit = NO;
        self.webView.multipleTouchEnabled = NO;

        if ([urlString hasPrefix:CONTENTBASE]) {
            if ([urlString isEqualToString:@"http://fscan.fashiontv.co.jp/fdbdev/"]) {
                [super setTitleNavigation:self];
            }else if ([urlString hasPrefix:[ CONTENTBASE stringByAppendingString:@"category/brands"]]) {
                [super setHomeCameraMenuNavigations:self];
            }else if ([urlString hasPrefix:[ CONTENTBASE stringByAppendingString:@"category"]]) {
                [super setHomeCameraNavigations:self];
            }else if ([urlString isEqualToString:[ CONTENTBASE stringByAppendingString:@"form-search"]]) {
                [super setHomeCameraMenuNavigations:self];
            }else{
                [super setBackCameraMenuNavigations:self];
            }
            
            if ([urlString isMatchedByRegex:@"result=true"]) {
                [super setHomeCameraMenuNavigations:self];
            }

            
        }else if ([urlString hasPrefix:[ BASEURL stringByAppendingString:@"/scan/list"]]) {
            [super setHomeCameraMenuNavigations:self];

        }else if ([urlString hasPrefix:@"http://zxc.cz/fdbdev"]) {
            [super setHomeCameraMenuNavigations:self];
            
        }else if ([urlString hasPrefix:@"http://fashiontv.co.jp//www.youtube.com"]) {
            [super setBackCameraMenuNavigations:self];
        }else{
            if([urlString rangeOfString:@"www.youtube.com"].location != NSNotFound){
                [super setHomeCameraMenuNavigations:self];
                self.webView.scalesPageToFit = YES;
                self.webView.multipleTouchEnabled = YES;

//            }else if(![urlString rangeOfString:@"www.youtube.com"].location != NSNotFound){
//                [super setHomeCameraMenuNavigations:self];
            }else if(![urlString hasSuffix:@"png"] && ![urlString hasSuffix:@"jpg"] &&![urlString hasSuffix:@"about:blank"]){
                [super setBackCameraMenuNavigations:self];
            }
        }
        
    }
    
    return NO;
}

@end
