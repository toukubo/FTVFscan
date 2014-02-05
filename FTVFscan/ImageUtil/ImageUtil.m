//
//  ImageUtil.m
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import "ImageUtil.h"
#import "UIImage+Resize.h"

@implementation ImageUtil

//////////////////////////// From FTVImageProcEngine start ////////////////////////////
#pragma mark - From FTVImageProcEngine
+ (UIImage*)imageResize:(UIImage*)srcImage
{
//    return [srcImage resizedImageToFitInSize:CGSizeMake(320, 9999) scaleIfSmaller:YES];
    CGSize fitInSize;
    if (srcImage.size.width < srcImage.size.height) {
        fitInSize = CGSizeMake(240, 320);
    }
    else {
        fitInSize = CGSizeMake(320, 240);
    }
    return [srcImage resizedImageToFitInSize:fitInSize scaleIfSmaller:YES];
}

//+ (UIImage*)imageResize:(UIImage*)srcImage saveWithName:(NSString*)imgName usingJPEG:(BOOL)jpeg
//{
//    UIImage *image = [FTVImageProcEngine imageResize:srcImage];
//    
//    NSString *savedImagePath = [PathForDocumentsResource(@"") stringByAppendingPathComponent:imgName];
//    
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
//    NSString* dir = paths[0];
//    
//    NSString *savedImagePath = [dir stringByAppendingPathComponent:imgName];
//    
//    NSData *imageData;
//    
//    if (jpeg) {
//        imageData = UIImageJPEGRepresentation(image, .5);
//    } else {
//        imageData = UIImagePNGRepresentation(image);
//    }
//    
//    [imageData writeToFile:savedImagePath atomically:NO];
//    
//    return image;
//}
//////////////////////////// From FTVImageProcEngine end ////////////////////////////

#pragma mark - Original method
+(BOOL)saveImage:(UIImage *)image withName:(NSString *)imageName usingJPEG:(BOOL)jpeg
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = paths[0];
    
    NSString *savedImagePath = [dir stringByAppendingPathComponent:imageName];
    NSData *imageData;
    
    if (jpeg) {
        imageData = UIImageJPEGRepresentation(image, .5);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }
    return [imageData writeToFile:savedImagePath atomically:NO];
}

+(UIImage *)getImageWithName:(NSString *)imageName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory    , NSUserDomainMask, YES);
    NSString* dir = paths[0];
    
    NSString *savedImagePath = [dir stringByAppendingPathComponent:imageName];
    
    return [UIImage imageWithContentsOfFile:savedImagePath];
}

+(UIImage *)getUIImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // NSLog(@"wxh: %lu x %lu", width, height);
    
    uint8_t* baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
    void* free_me = 0;
    if (true) {
        uint8_t* tmp = baseAddress;
        int bytes = bytesPerRow*height;
        free_me = baseAddress = (uint8_t*)malloc(bytes);
        baseAddress[0] = 0xdb;
        memcpy(baseAddress,tmp,bytes);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext =
    CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,
                          kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
    CGImageRef capture = CGBitmapContextCreateImage(newContext);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    free(free_me);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    UIImage *scrn = [[UIImage alloc] initWithCGImage:capture
                                               scale:1.0
                                         orientation:UIImageOrientationRight];
    
    CGImageRelease(capture);
    return scrn;
}
@end
