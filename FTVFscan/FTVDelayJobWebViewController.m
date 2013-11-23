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
    
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setFrame:CGRectMake(0, 0, 45, 45)];
//    [backButton setTitle:@"back" forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
  
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [homeButton setImage:[UIImage imageNamed:@"home_white.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem1 = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [cameraButton setImage:[UIImage imageNamed:@"camera_white.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem2 = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    NSArray *actionButtonItems = @[leftItem1, leftItem2];
    self.navigationItem.leftBarButtonItems = actionButtonItems;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];

    
    if (redirectUrl != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:redirectUrl]];

        [self.webView loadRequest:request];
    }
    
    if ([[self.view subviews] count] == 0) {
        // If this controller was init from FTVAppDelegate - showModalPopupWindow,
        // the webview is not added to view
        [self.view addSubview:self.webView];
    }
}

- (void)cameraAction
{
    [super cameraAction:self];
}

- (void)homeAction
{
    [super homeAction:self];
}


- (void)backAction
{
    if([self.webView canGoBack])
    {
        [self.webView goBack];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)needOpenExternalSafari:(NSString*)url
{
    if ([url isMatchedByRegex:@"target=_blank"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldOverrideUrlLoading:(NSString *)urlString
{
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
        if ([action isEqualToString:@"Camera"]) {
            DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];
            [menuController setRootController:controller animated:YES];
        }
        else if([action isEqualToString:@"Gallery"])
        {
            DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVGalleryViewController"];
            [menuController setRootController:controller animated:YES];
        }
        
        return YES;
    }
                 // TODO gailya, handle this later
//        else if (url.contains(".ahtml")) {
//        URL urlObject = null;
//        try {
//            urlObject = new URL(url);
//        } catch (MalformedURLException e) {
//            e.printStackTrace();
//        }
//        InputStream is = null;
//        try {
//            is = urlObject.openStream();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//        String thehtml = null;
//        try {
//            thehtml = IOUtils.toString(is);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//        
//        for (Iterator iterator = this.attributeSet.keySet().iterator(); iterator.hasNext(); ) {
//            String key = (String) iterator.next();
//            String value = this.attributeSet.get(key);
//            thehtml = thehtml.replaceAll("\\$\\{" + key + "\\}", value);
//        }
//        view.loadDataWithBaseURL("file:///android_asset/", thehtml, "text/html", "UTF-8", null);
//        
//        return YES;
//        
//    }
    return NO;
}

@end
