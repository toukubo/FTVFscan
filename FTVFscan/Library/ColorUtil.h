//
//  ColorUtil.h
//  ec
//
//  Created by synnex on 5/5/11.
//  Copyright 2011 EIJUS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ColorUtil : NSObject 

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
+(UIColor *) headerColor;
+(UIColor *)backgroundColor;

@end
