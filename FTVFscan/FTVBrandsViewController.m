//
//  FTVBrandsViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVBrandsViewController.h"

#import "RegexKitLite.h"


@interface FTVBrandsViewController ()
{
    BOOL isGoBack;
    BOOL skipUrl;
    int count;
    NSMutableArray *urlHolderArray;
}

@end

@implementation FTVBrandsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    count = 0;
    skipUrl = NO;
    urlHolderArray = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    _brandsWebView.delegate = self;
    [_brandsWebView setScalesPageToFit:YES];
    for (id subview in _brandsWebView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    
    [_brandsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: [ BASEURL stringByAppendingString:@"brands"]]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonClick:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
}


- (void)backAction
{
    if([_brandsWebView canGoBack])
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
            [_brandsWebView goBack];
        }
    }
}

#pragma --
#pragma webview delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [self navBarSlideLeft:!isGoBack];
    [self statusIndicatorShow];
}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [self statusIndicatorHide];
//    isGoBack = NO;
//}

- (void)statusIndicatorShow
{
    [self.loadingView show];
}

- (void)statusIndicatorHide
{
    [self.loadingView hide];
}


- (void)loadUrl:(NSString*)url
{
    NSLog(@"loadUrl...%@", url);
    
    
    if (!IsEmpty(url)) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_brandsWebView loadRequest:request];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    NSLog(@"webViewDidFinishLoad,,,");
    [self statusIndicatorHide];
    isGoBack = NO;
    
    for (id subview in _brandsWebView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
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


-(void)doneButtonClick:(NSNotification*)aNotification
{
    //Do whatever you want here
    if ([_brandsWebView canGoBack]) {
        [_brandsWebView goBack];
        isGoBack = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma --
#pragma webView delegates

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSString *urlString = request.URL.absoluteString;
//    DLog(@"%@", urlString);
//    if ([self needOpenExternalSafari:urlString]) {
//        [FTVImageProcEngine openSafari:urlString];
//        return NO;
//    }
//    
//    return YES;
//}


- (BOOL)needOpenExternalSafari:(NSString*)url
{
    if ([url isMatchedByRegex:@"target=_blank"]) {
        return YES;
    }
    
    return NO;
}

-(IBAction)OpenMenu:(id)sender
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showRightController:YES];
    
}


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
            [_brandsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"file:///android_asset/" ofType:@"*"] isDirectory:NO]]];
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
        _brandsWebView.scalesPageToFit = NO;
        _brandsWebView.multipleTouchEnabled = NO;
        
        if ([urlString hasPrefix:CONTENTBASE]) {
            if ([urlString isEqualToString:@"http://fscan.fashiontv.co.jp/fdbdev/"]) {
                [super setTitleNavigation:self];
            }else if ([urlString hasPrefix:[ CONTENTBASE stringByAppendingString:@"category/brandlogo_"]]) {
                [super setBackCameraMenuNavigations:self];
            }else if ([urlString hasPrefix:[ CONTENTBASE stringByAppendingString:@"category/brands"]]) {
                [super setHomeCameraMenuNavigations:self];
            }else if ([urlString hasPrefix:[ CONTENTBASE stringByAppendingString:@"category"]]) {
                [super setHomeCameraNavigations:self];
            }else if ([urlString isEqualToString:[ CONTENTBASE stringByAppendingString:@"form-search"]]) {
                [super setHomeCameraMenuNavigations:self];
            }else{
                [super setBackCameraMenuNavigations:self];
            }
        }else if ([urlString hasPrefix:[ BASEURL stringByAppendingString:@"/scan/list"]]) {
            [super setHomeCameraMenuNavigations:self];
            
        }else if ([urlString hasPrefix:@"http://zxc.cz/fdbdev"]) {
            [super setHomeCameraMenuNavigations:self];
            
        }else if ([urlString hasPrefix:@"http://fashiontv.co.jp//www.youtube.com"]) {
            [super setBackCameraMenuNavigations:self];
        }else{
            if(![urlString hasPrefix:@"http://www.youtube.com"]){
                [super setBackCameraNavigations:self];
                _brandsWebView.scalesPageToFit = YES;
                _brandsWebView.multipleTouchEnabled = YES;
                
            }
        }
        
        if ([urlString isMatchedByRegex:@"result=true"]) {
            [super setHomeCameraMenuNavigations:self];
        }
        
    }
    return NO;
}



@end
