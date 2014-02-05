//
//  GAZIRUAuthLogic.h
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAZIRUAuthLogic : NSOperation

@property (nonatomic, readonly) NSString *resultString;
-(void)executeGAZIRUAuth;
@end
