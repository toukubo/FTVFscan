//
//  NSString+NSStringUtils.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-10-30.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import "NSString+NSStringUtils.h"

@implementation NSString (NSStringUtils)

- (BOOL)isEmpty
{
    return self == nil
    || ([self respondsToSelector:@selector(length)]
        && [(NSData *)self length] == 0)
    || ([self respondsToSelector:@selector(count)]
        && [(NSArray *)self count] == 0);
}

@end
