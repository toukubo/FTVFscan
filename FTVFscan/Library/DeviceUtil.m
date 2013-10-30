//
//  DeviceUtil.m
//  Hai
//
//  Created by Alsor Zhou on 12-12-9.
//  Copyright (c) 2012年 EIJUS, LLC. All rights reserved.
//

#import "DeviceUtil.h"

@implementation DeviceUtil

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@end
