
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "FTVCamOverlayView.h"

@protocol AVCamViewControllerDelegate <NSObject>
- (void)didFinishedTakenPictureWithPath:(NSString*)imagePath;

@optional
- (void)didCancelCamera;

@end
@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface AVCamViewController : UIViewController <UIImagePickerControllerDelegate,FTVCamOverlayViewDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
{
    id                      delegate;
    
    FTVCamOverlayView       *overlayView;
    
    UIImageView             *indicator;
    
    UIButton                *stillButton;
    UIButton                *homeButton;
}

@property (nonatomic, retain) AVCamCaptureManager           *captureManager;
@property (nonatomic, retain) UIView                        *videoPreviewView;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer    *captureVideoPreviewLayer;
@property (nonatomic, assign) id                            delegate;
@end

