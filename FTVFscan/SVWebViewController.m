//
//  SVWebViewController.m
//  SVIPad
//
//  Created by Tim Tretyak on 24.02.13.
//  Copyright (c) 2013 studiovoice. All rights reserved.
//

#import "SVWebViewController.h"
#import "FTVAppDelegate.h"
#import "MSNavigationPaneViewController.h"
#import "SVUtilities.h"

@interface SVWebViewController ()

@end

@implementation SVWebViewController

@synthesize webView=_webView;

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
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        [self.view addSubview:_webView];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    [self setupNavBarDesign];
    
    [self setupNavBarButtons];
    
    // Setting title view
    if(!self.navigationItem.titleView){
        UIImageView *barImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 110, 26)];
        barImg.image = [UIImage imageNamed:@"logoPad"];
        self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 110, 27)];
        [self.navigationItem.titleView addSubview:barImg];
    }
}

- (void)navigationPaneBarButtonItemTapped:(id)sender;
{
    FTVAppDelegate *appDelegate = (FTVAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.navigationPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES completion:nil];
}

- (void)backPressed:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[SVUtilities baseURLWith:nil]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Request = %@",request.URL);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.busyIndicator.hidden = NO;
    [self.busyIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if([webView canGoBack])
        self.navigationItem.leftBarButtonItem.enabled = YES;
    else
        self.navigationItem.leftBarButtonItem.enabled = NO;
    
    [self.busyIndicator stopAnimating];
    self.busyIndicator.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.busyIndicator stopAnimating];
    self.busyIndicator.hidden = YES;
}

- (void)setupNavBarDesign
{
    UIImage *back = [SVUtilities imageWithColor:[UIColor blackColor] andSize:CGSizeMake(20, 20)];
    // IOS 6
    [[UINavigationBar appearance] setBackgroundImage:back forBarMetrics:UIBarMetricsDefault];
    // IOS 5
    [self.navigationController.navigationBar setBackgroundImage:back forBarMetrics:UIBarMetricsDefault];
    
    // Tint Color for button item
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont systemFontOfSize:19], UITextAttributeFont,nil]];
    
/*    int imageSize = 10;
    UIImage *barBackBtnImg = [[UIImage imageNamed:@"BarButtonBack1"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, imageSize, 10, 10)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:barBackBtnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  */  
}

- (void) setupNavBarButtons
{
    // Custom button for left side menu activation
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, 5, 35, 30);
    [b setBackgroundImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    [b setBackgroundImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateHighlighted];
    b.showsTouchWhenHighlighted = YES;
    [b addTarget:self action:@selector(navigationPaneBarButtonItemTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Shifting button to left edge of navbar
    //    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    //    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 8, 0);
    //    [backButtonView addSubview:b];
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    if(!self.busyIndicator)
        self.busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    self.busyIndicator.hidden = YES;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:b],[[UIBarButtonItem alloc] initWithCustomView:self.busyIndicator],nil];
    
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
    b2.frame = CGRectMake(0, 5, 35, 30);
    [b2 setBackgroundImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [b2 setBackgroundImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateHighlighted];
    [b2 setBackgroundImage:[UIImage imageNamed:@"NavBackButtonDisabled"] forState:UIControlStateDisabled];
    b2.showsTouchWhenHighlighted = YES;
    [b2 addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:b2];;
    //    self.navigationItem.rightBarButtonItem = back;

}



@end
