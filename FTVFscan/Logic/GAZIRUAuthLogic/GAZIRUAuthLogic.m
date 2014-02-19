//
//  GAZIRUAuthLogic.m
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <RTSearchKit/RTSearchApi.h>

#import "GAZIRUAuthLogic.h"

@implementation GAZIRUAuthLogic

-(void)executeGAZIRUAuth
{
    NSDate *startTime = [NSDate date];
    @try {
        _resultString = [[[RTSearchApi alloc] init] RTSearchAuth];
    }
    @finally {
        NSDate *endTime = [NSDate date];
        NSString *costTime = [NSString stringWithFormat:@"%.3f", [endTime timeIntervalSinceDate:startTime]];
        NSLog(@"GAZIRU authentication end. result[%@], costTime[%@]", _resultString, costTime);
    }
}
@end
