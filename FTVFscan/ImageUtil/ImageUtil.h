//
//  ImageUtil.h
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject

+(UIImage*)imageResize:(UIImage*)srcImage;
+(BOOL)saveImage:(UIImage *)image withName:(NSString *)imageName usingJPEG:(BOOL)jpeg;
+(UIImage *)getImageWithName:(NSString *)imageName;
+(UIImage *)getUIImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
