//
//  NSString+Random.m
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/20.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)
NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

// see -> http://stackoverflow.com/questions/2633801/generate-a-random-alphanumeric-string-in-cocoa
+(NSString *)genRandStringLength:(int)len
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}
@end
