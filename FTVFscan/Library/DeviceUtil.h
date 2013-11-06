//
//  DeviceUtil.h
//  Hai
//
//  Created by Alsor Zhou on 12-12-9.
//  Copyright (c) 2012年 EIJUS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@end
