//
//  CameraManager.m
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import "CameraManager.h"
@interface CameraManager ()
@property (nonatomic, retain) AVCaptureDevice *device;                      // Capture Device
@property (nonatomic, retain) AVCaptureDeviceInput *deviceInput;            // Capture Input
@property (nonatomic, retain) AVCaptureVideoDataOutput *videoDataOutput;    // Capture Output
@property (nonatomic, retain) AVCaptureSession *session;                    // Capture Session
@end
@implementation CameraManager

/**
 Initialize camera
 @param delegate id<AVCaptureVideoDataOutputSampleBufferDelegate>
 @param previewFrame CGRect
 */
-(void)openDriverWithDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate
                 previewFrame:(CGRect)previewFrame
{
    @synchronized(self) {
        // Retain ConfigManager
        _configManager = [[CameraConfigurationManager alloc] init];
        
        // Get AVCaptureDevice and setup
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [_configManager loadCameraParametersWithDevice:_device];
        
        // Get AVCaptureDeviceInput
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:NULL];
        
        // Create AVCaptureVideoDataOutput and setup
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_configManager loadCameraParametersWithVideoDataOutput:_videoDataOutput delegate:delegate];
        
        // Create AVCaptureSession and setup
        _session = [[AVCaptureSession alloc] init];
        if (_deviceInput != nil && _videoDataOutput != nil) {
            [_session addInput:_deviceInput];
            [_session addOutput:_videoDataOutput];
        }
        [_configManager loadCameraParametersWithSession:_session device:_device];
        
        // Get AVCaptureVideoPreviewLayer and setup
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        [_configManager loadCameraParametersWithVideoPreviewLayer:_videoPreviewLayer previewFrame:previewFrame];
    }
}

/**
 Start preview
 */
-(void)startPreview
{
    if (_session != nil) {
        // Start session and get camera resolution
        [_session startRunning];
    }
}

/**
 Stop preview
 */
-(void)stopPreview
{
    if (_session != nil) {
        // Stop session
        [_session stopRunning];
    }
}

/**
 Close camera
 */
-(void)closeDriver
{
    // Release PreviewLayer
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = nil;
    
    // Release AVCaptureOutput and AVCaptureInput
	for (AVCaptureOutput *output in _session.outputs) {
		[_session removeOutput:output];
	}
	for (AVCaptureInput *input in _session.inputs) {
		[_session removeInput:input];
	}
}
@end
