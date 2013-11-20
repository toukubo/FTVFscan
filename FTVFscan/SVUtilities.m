//
//  SVUtilities.m
//  SVIPad
//
//  Created by Tim Tretyak on 24.02.13.
//  Copyright (c) 2013 studiovoice. All rights reserved.
//

#import "SVUtilities.h"

@implementation SVUtilities

+(NSString *)baseURLWith:(NSString *)relative
{
    if(relative)
        return [NSString stringWithFormat:@"http://studiovoice.jp/%@",relative];
    else
        return @"http://studiovoice.jp/";
}

+(UIColor *)navMenuBackground
{
//    return [UIColor colorWithRed:156.0/255.0 green:156.0/255.0 blue:158.0/255.0 alpha:1.0];
    return [UIColor blackColor];
}

// Make image from color for TabBar tint
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retval;
}


@end
