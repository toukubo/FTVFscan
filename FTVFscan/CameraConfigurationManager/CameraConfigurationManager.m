//
//  CameraConfigurationManager.m
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import "CameraConfigurationManager.h"

@implementation CameraConfigurationManager

/**
 Load AVCaptureDevice settings.
 @param device AVCaptureDevice
 */
-(void)loadCameraParametersWithDevice:(AVCaptureDevice *)device
{
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
        // AVCaptureFocusMode
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        
        // AVCaptureExposureMode
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        
        // AVCaptureWhiteBalanceMode
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        
        // AVCaptureFlashMode
        if ([device isFlashModeSupported:AVCaptureFlashModeOff])
            device.flashMode = AVCaptureFlashModeOff;
        
        // AVCaptureTorchMode
        if ([device isTorchModeSupported:AVCaptureTorchModeOff])
            device.torchMode = AVCaptureTorchModeOff;
        
        // Commit
        [device unlockForConfiguration];
    }
}

/**
 Load AVCaptureVideoDataOutput settings.
 @param videoDataOutput AVCaptureVideoDataOutput
 @param delegate id<AVCaptureVideoDataOutputSampleBufferDelegate>
 */
-(void)loadCameraParametersWithVideoDataOutput:(AVCaptureVideoDataOutput *)videoDataOutput
                                      delegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate
{
    NSMutableDictionary* settings = [NSMutableDictionary dictionary];
    // PixelFormat setting
    [settings setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    videoDataOutput.videoSettings = settings;
    
    // Discard frame in processing
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // Process in main thread
    [videoDataOutput setSampleBufferDelegate:delegate queue:dispatch_get_main_queue()];
}

/**
 Load AVCaptureSession settings.
 @param session AVCaptureSession
 @param device AVCaptureDevice
 */
-(void)loadCameraParametersWithSession:(AVCaptureSession *)session
                                device:(AVCaptureDevice *)device
{
    [session beginConfiguration];
    
    // Set camera resolution
    session.sessionPreset = AVCaptureSessionPreset640x480;
    
    // Commit
    [session commitConfiguration];
}

/**
 Load AVCaptureVideoPreviewLayer settings
 @param videoPreviewLayer AVCaptureVideoPreviewLayer
 @param previewFrame CGRect
 */
-(void)loadCameraParametersWithVideoPreviewLayer:(AVCaptureVideoPreviewLayer *)videoPreviewLayer
                                    previewFrame:(CGRect)previewFrame
{
    // Draw preview with AspectFill
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // Set PreviewLayer size
    videoPreviewLayer.frame = previewFrame;
}
@end
