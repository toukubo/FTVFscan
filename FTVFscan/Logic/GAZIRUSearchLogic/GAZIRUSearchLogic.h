//
//  GAZIRUSearchLogic.h
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface GAZIRUSearchLogic : NSOperation

@property (nonatomic, readonly) UIImage *queryImage;
@property (nonatomic, readonly) NSMutableArray *resultArray;
-(void)executeGAZIRUSearch:(CMSampleBufferRef)sampleBuffer;
@end
