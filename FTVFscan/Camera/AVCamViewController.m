#import "AVCamViewController.h"
#import "AVCamCaptureManager.h"

static void *AVCamFlashModeObserverContext = &AVCamFlashModeObserverContext;

@interface AVCamViewController () <UIGestureRecognizerDelegate>
@end

@interface AVCamViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@interface AVCamViewController (private)
- (void)updateButtonStates;
- (void)stopCamPreview;
- (void)startCamCapture;
@end


@implementation AVCamViewController
@synthesize captureManager, videoPreviewView, captureVideoPreviewLayer, delegate;

#pragma mark -
#pragma mark Initialization
- (void)dealloc
{
    //IMPORTANT: remove capture manger observers (it will not dealloc if we didn't remove these observer)
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[captureManager deviceConnectedObserver]];
    [notificationCenter removeObserver:[captureManager deviceDisconnectedObserver]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [captureManager release];
    [videoPreviewView release];
    [captureVideoPreviewLayer release];
    [indicator release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Nav Bar Background
        
        UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        navigationView.backgroundColor = [UIColor blackColor];
//        [navigationView addSubview:titleView];
        [self.view addSubview:navigationView];
        
        // take photo button
        stillButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *shutterImageNormal = [UIImage imageNamed:@"go-camera.png"];
        UIImage *shutterImagePressed = [UIImage imageNamed:@"go-camera.png"];
        [stillButton setFrame:CGRectMake((self.view.frameSizeWidth - shutterImageNormal.size.width) / 2,
                                         self.view.frameSizeHeight - shutterImageNormal.size.height - 60,
                                         shutterImageNormal.size.width,
                                         shutterImageNormal.size.height)];
        [stillButton setImage:shutterImageNormal forState:UIControlStateNormal];
        [stillButton setImage:shutterImagePressed forState:UIControlStateHighlighted];
        [stillButton setBackgroundColor:[UIColor clearColor]];
        [stillButton addTarget:self action:@selector(captureStillImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:stillButton];
        
        
        UIButton *drawerButton = [[UIButton alloc] initWithFrame:CGRectMake(278, 7, 35, 30)];
        UIImage *drawerImage = [UIImage imageNamed:@"menuIcon.png"];
        [drawerButton setImage:drawerImage forState:UIControlStateNormal];
        [drawerButton addTarget:self action:@selector(drawerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:drawerButton];
        
        UIButton *home_Button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 24, 24)];
        UIImage *homeButtonImage = [UIImage imageNamed:@"home_white.png"];
        [home_Button setImage:homeButtonImage forState:UIControlStateNormal];
        [home_Button addTarget:self action:@selector(homeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:home_Button];
        
    }
    
    return self;
}

#pragma mark -
#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

#pragma mark - Helper
- (void)homeButtonPressed:(id)sender
{
    
    FTVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate switchSceneToTabController];
    
    // TODO:
//    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
//    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    [menuController setRootViewController:controller];
//    [menuController showRootController:YES];
//    [self stopCamPreview];
//    [self stopCamPreview];
//    [self dismissViewControllerAnimated:YES completion:^{
//        
////        DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
////        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
////        [menuController setRootViewController:controller];
////        [menuController showRootController:YES];
//        
//        FTVAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        [appDelegate switchSceneToTabController];
//        
//    }];
    
    DLine;
}


-(void)drawerButtonPressed:(id)sender
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController setRootViewController:self];
    [menuController showRightController:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startCamCapture];
}

- (void)captureStillImage:(id)sender
{
    [stillButton setEnabled:NO];
    
    // Capture a still image
    [[self captureManager] captureStillImage]; // take picture, but not wait finished
}

- (void)startCamCapture
{
    if ([self captureManager] == nil) {
        AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
        [self setCaptureManager:manager];
        [manager release];
        [[self captureManager] setDelegate:self];
        
        if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
            AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
            UIView *view = [self videoPreviewView];
            
            view.backgroundColor = [UIColor blackColor];
            
            CALayer *viewLayer = [view layer];
            [viewLayer setMasksToBounds:YES];
            
            CGRect bounds = [view bounds];
            bounds = CGRectMake(bounds.origin.x,
                                bounds.origin.y,
                                bounds.size.width,
                                bounds.size.height);
            [newCaptureVideoPreviewLayer setFrame:bounds];
            
            if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
                [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
            }
            
            [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            
            [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
            
            [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            [newCaptureVideoPreviewLayer release];
            
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[[self captureManager] session] startRunning];
            });
        }
        
        // support devices which not support focus, like ipod
        if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
            [self performSelector:@selector(setInitialFocus) withObject:nil afterDelay:0.5];
        } else {
            [self updateButtonStates];
        }
	}
}

- (void)stopCamPreview
{
    [self setCaptureVideoPreviewLayer:nil];
    
    // Stop the session. This is done asychronously since -startRunning doesn't return until the session is running.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[self captureManager] session] stopRunning];
    });
}
// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([captureVideoPreviewLayer isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)setInitialFocus
{
    // default auto focus at screen center
    CGPoint viewCoordinates = CGPointMake(160, 240);
    CGPoint poi = [self convertToPointOfInterestFromViewCoordinates:viewCoordinates];
    [captureManager continuousFocusAtPoint:poi];
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
    [stillButton setEnabled:YES];
}

@end

@implementation AVCamViewController (AVCamCaptureManagerDelegate)
- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:LOCALIZE(@"ok")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}

- (void) captureManagerStillImageCaptured:(NSString*)localImagePath
{
    [SVProgressHUD dismiss];
    
    // stop camera preview
    [self stopCamPreview];
    
    if ([delegate respondsToSelector:@selector(didFinishedTakenPictureWithPath:)]) {
        [delegate didFinishedTakenPictureWithPath:localImagePath];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)cancelShooting
{
    [SVProgressHUD dismiss];
    
    if ([delegate respondsToSelector:@selector(didCancelCamera)]) {
        [delegate didCancelCamera];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}

@end
