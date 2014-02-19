//
//  CameraConfigurationManager.h
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface CameraConfigurationManager : NSObject

-(void)loadCameraParametersWithDevice:(AVCaptureDevice *)device;
-(void)loadCameraParametersWithVideoDataOutput:(AVCaptureVideoDataOutput *)videoDataOutput
                                      delegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;
-(void)loadCameraParametersWithSession:(AVCaptureSession *)session
                                device:(AVCaptureDevice *)device;
-(void)loadCameraParametersWithVideoPreviewLayer:(AVCaptureVideoPreviewLayer *)videoPreviewLayer
                                    previewFrame:(CGRect)previewFrame;
@end
