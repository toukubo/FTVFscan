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
//    -(UIImage*)resizedImageToFitInSize:(CGSize*)size scaleIfSmaller:(BOOL)scale;
    return [srcImage resizedImageToSize:CGSizeMake(500, 500)];
}


@end
