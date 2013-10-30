//
//  ColorUtil.m
//  ec
//
//  Created by synnex on 5/5/11.
//  Copyright 2011 EIJUS. All rights reserved.
//

#import "ColorUtil.h"


@implementation ColorUtil

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	// String should be 6 or 8 characters
	if ([cString length] < 6) return [UIColor blackColor];
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	if ([cString length] != 6) return [UIColor blackColor];
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
//    
//    if ([stringToConvert isEqualToString:@"639D30"]) {
//        DLog(@"r = %u", r);
//        DLog(@"g = %u", g);
//        DLog(@"b = %u", b);
//        
//    }
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}

+(UIColor *)headerColor {
	
	return [UIColor colorWithRed:2.0/255.0 green:41.0/255.0 blue:67.0/255.0 alpha:1.0];
}

+(UIColor *)backgroundColor {
	
	return [UIColor colorWithRed:153.0/255.0 green:180.0/255.0 blue:199.0/255.0 alpha:1.0];
}

@end
