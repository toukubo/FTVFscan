//
//  FTVCameraViewController.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "FTVCameraViewController.h"
#import "FTVDelayJobWebViewController.h"
#import "MSNavigationPaneViewController.h"
#import "DDMenuController.h"
#import "AVCamCaptureManager.h"
#import "AVCamViewController.h"

static void *AVCamFlashModeObserverContext = &AVCamFlashModeObserverContext;

@interface FTVCameraViewController () <UIGestureRecognizerDelegate>
@end

@interface FTVCameraViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@interface FTVCameraViewController (Private)
- (void)updateButtonStates;
- (void)stopCamPreview;
- (void)startCamCapture;
@end

@interface FTVCameraViewController ()
{
    FTVAppDelegate              *appDelegate;
    
    BOOL                        returnFromPicker;      // Workaround while this workflow is not completed
    NSString                    *redirectUrl;
}

@end

@implementation FTVCameraViewController
@synthesize popoverHolder;
@synthesize captureManager, videoPreviewView, captureVideoPreviewLayer, delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    appDelegate = (FTVAppDelegate *)[UIApplication sharedApplication].delegate;
    returnFromPicker = NO;
    
    if ([appDelegate checkLoginCredential]) {
        // bring up camera
        [self switchSceneToCamera];
        DLog(@"but true");
    } else {
        [self switchSceneToRegisterController];
        DLog(@"but false. going to regist ");
    }
    [super setHomeMenuNavigations:self];

}

- (void)viewDidAppear:(BOOL)animated
{
    if(!returnFromPicker){
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (returnFromPicker) {
        returnFromPicker = NO;
    }
    
    [SVProgressHUD dismiss];
}

- (void)switchSceneToCamera
{
    avCamera = [[AVCamViewController alloc] init];
    [avCamera setDelegate:self];
    [super setHomeMenuNavigations:avCamera];

    if (!stillButton.superview) {
        stillButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *shutterImageNormal = [UIImage imageNamed:@"scan.png"];
        UIImage *shutterImagePressed = [UIImage imageNamed:@"scan.png"];
        [stillButton setFrame:CGRectMake((self.view.frameSizeWidth - 60) / 2,
                                         self.view.frameSizeHeight - 60 - 20,
                                         60,
                                         60)];
        [stillButton setImage:shutterImageNormal forState:UIControlStateNormal];
        [stillButton setImage:shutterImagePressed forState:UIControlStateHighlighted];
        [stillButton setBackgroundColor:[UIColor clearColor]];
        [stillButton addTarget:self action:@selector(captureStillImage:) forControlEvents:UIControlEventTouchUpInside];
        [avCamera.view addSubview:stillButton];
    }
    
    [self startCamCapture];
    
//    AVCamViewController *avCamera = [[AVCamViewController alloc] init];
//    [avCamera setDelegate:self];
//    
//    avCamera.view.frame = self.cameraView.bounds;
//    [self.view addSubview:avCamera.view];
//    [self addChildViewController:avCamera];
//    [avCamera didMoveToParentViewController:self];
    [self presentViewController:avCamera animated:YES completion:nil];
}

- (void)switchSceneToRegisterController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"ftvNavRegisterViewController"];
    [self presentViewController:controller animated:YES completion:nil];
    
    __block id complete;
    
    complete = [[NSNotificationCenter defaultCenter] addObserverForName:kNotifyRegisterFinished
                                                                 object:controller
                                                                  queue:nil
                                                             usingBlock:^(NSNotification *note) {
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:complete];
                                                                 
                                                                 //gonna do re-checking if the regisration is completed. if not ,eternal loop.
                                                                 if ([appDelegate checkLoginCredential]) {
//                                                                    goto camera tab bar controller
                                                                     [self switchSceneToCamera];
                                                                     DLog(@"but true");
                                                                 } else {
                                                                     [self switchSceneToRegisterController];
                                                                     DLog(@"but false. going to regist ");
                                                                 }
                                                             }];
}


- (void)doImageProcessInBackgroundWithPath:(NSString*)imagePath
{
    UIImage *pickedImage = [UIImage imageWithContentsOfFile:imagePath];
    
    DLog(@"IMG pre proessed: W - %0.f px, H - %0.f px", pickedImage.size.width, pickedImage.size.height);
    
    for (int i = 0; i < TEST_TIME; i++) {
        NSDate *start = [NSDate date];
        pickedImage = [FTVImageProcEngine imageResize:pickedImage saveWithName:[NSString genRandStringLength:10] usingJPEG:YES];
        NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
        NSLog(@"imageResize Execution Time: %f", executionTime);
    }
    
    for (int i = 0; i < TEST_TIME; i++) {
        NSString *brand_slug = [FTVImageProcEngine executeApi:pickedImage];
        
        NSData *imageData = UIImagePNGRepresentation(pickedImage);
        
        DLog(@"image data size - %d KB", imageData.length / 1024);
        
        if (IsEmpty(brand_slug) || [brand_slug isEqualToString:@"failure"]) {
            [appDelegate performSelectorOnMainThread:@selector(showModalPopupWindow) withObject:nil waitUntilDone:NO];
        } else {
            NSDate *start = [NSDate date];
            // no need to post data if BRAND was failure
            // step 1 - post brand slug, and get response for "id=xxx"
            [FTVImageProcEngine postWithBrand:brand_slug
                               withStartBlock:^{
                               } withFinishBlock:^(BOOL success, NSString *resp) {
                                   if (success) {
                                       NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:start];
                                       NSLog(@"postData Execution Time: %f", executionTime);
                                       
                                       // step 2 - post image data
                                       [FTVImageProcEngine postData:imageData
                                                          withBrand:brand_slug
                                                             withId:resp
                                                     withStartBlock:nil
                                                    withFinishBlock:^(BOOL success, NSString *resp) {
                                                        // TODO: should we do some extra stuff here?
                                                    } withFailedBlock:^(BOOL success, NSString *resp) {
                                                        //
                                                    }];
                                       
                                       redirectUrl = [FTVImageProcEngine encapsulateById:resp];
                                       if (![redirectUrl isMalform]) {
                                           [self performSelectorOnMainThread:@selector(switchSceneToResultController) withObject:nil waitUntilDone:NO];
                                       }
                                   }
                               } withFailedBlock:^(BOOL success, NSString *resp) {
                               }];
            
            DLog(@"IMG: W - %0.f px, H - %0.f px", pickedImage.size.width, pickedImage.size.height);
        }
    }
}

- (void)switchSceneToResultController
{
    [self performSegueWithIdentifier:@"presentDelayJobWebViewController" sender:self];
}
#pragma mark - AVCamViewControllerDelegate
- (void)didFinishedTakenPictureWithPath:(NSString*)imagePath
{
    returnFromPicker = YES;
    
    [SVProgressHUD show];
    [self performSelectorInBackground:@selector(doImageProcessInBackgroundWithPath:) withObject:imagePath];
}

- (void)didCancelCamera
{
    // TODO: should we support cancel ?
    returnFromPicker = YES;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentDelayJobWebViewController"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[FTVDelayJobWebViewController class]]) {
                ((FTVDelayJobWebViewController*)vc).redirectUrl = redirectUrl;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Nav Bar Button Helper
- (IBAction)openHome:(id)sender {
    [self stopCamPreview];
    [self dismissViewControllerAnimated:YES completion:^{
        
        DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
        [menuController setRootViewController:controller];
        [menuController showRootController:YES];
        
    }];
}

- (IBAction)openGallery:(id)sender {
    [self stopCamPreview];
    
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVGalleryViewController"];
    [menuController setRootController:controller animated:YES];
}

//-(IBAction)OpenMenu:(id)sender
//{
//    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
//    [menuController showRightController:YES];
//}

#pragma mark -
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
            
            [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            
            [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
            
            [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
//            [newCaptureVideoPreviewLayer release];
            
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
    
//    if ([captureVideoPreviewLayer isMirrored]) {
//        viewCoordinates.x = frameSize.width - viewCoordinates.x;
//    }
    
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

@implementation FTVCameraViewController (AVCamCaptureManagerDelegate)
- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:LOCALIZE(@"ok")
                                                  otherButtonTitles:nil];
        [alertView show];
//        [alertView release];
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
//    [avCamera willMoveToParentViewController:nil];
//    [avCamera.view removeFromSuperview];
//    [avCamera removeFromParentViewController];
    [self dismissViewControllerAnimated:YES completion:^{    }];
}

- (void)cancelShooting
{
    [SVProgressHUD dismiss];
    
    if ([delegate respondsToSelector:@selector(didCancelCamera)]) {
        [delegate didCancelCamera];
    }
//    [avCamera.view removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}

@end
