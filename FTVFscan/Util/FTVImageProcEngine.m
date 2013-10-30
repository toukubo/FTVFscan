//
//  FTVImageProcEngine.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-10-30.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import "FTVImageProcEngine.h"

/**
 * FTVImageProcEngine is used to process images after pick from camera or photo gallery.
 *
 * Currently, it only support resize to W500xH500 px.
 */
@implementation FTVImageProcEngine

+ (UIImage*)imageResize:(UIImage*)srcImage
{
    return [srcImage resizedImageToFitInSize:CGSizeMake(500, 500) scaleIfSmaller:YES];
}

+ (UIImage*)imageResize:(UIImage*)srcImage saveWithName:(NSString*)imgName usingJPEG:(BOOL)jpeg
{
    UIImage *image = [FTVImageProcEngine imageResize:srcImage];
    
    NSString *savedImagePath = [PathForDocumentsResource(@"") stringByAppendingPathComponent:imgName];
    
    NSData *imageData;
    
    if (jpeg) {
        imageData = UIImageJPEGRepresentation(image, .5);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }
    
    [imageData writeToFile:savedImagePath atomically:NO];
    
    return image;
}

@end
