//
//  SVUtilities.h
//  SVIPad
//
//  Created by Tim Tretyak on 24.02.13.
//  Copyright (c) 2013 studiovoice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVUtilities : NSObject

+(UIColor *)navMenuBackground;
+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+(NSString *)baseURLWith:(NSString *)relative;

@end
