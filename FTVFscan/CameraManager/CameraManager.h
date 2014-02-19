//
//  CameraManager.h
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "CameraConfigurationManager.h"

@interface CameraManager : NSObject
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *videoPreviewLayer;    // Camera Preview Layer
@property (nonatomic, retain) CameraConfigurationManager *configManager;        // Config Manager
-(void)openDriverWithDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate
                 previewFrame:(CGRect)previewFrame;
-(void)startPreview;
-(void)stopPreview;
-(void)closeDriver;
@end
