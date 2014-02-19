//
//  GAZIRUSearchLogic.m
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/17.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <RTSearchKit/RTSearchApi.h>
#import "GAZIRUSearchLogic.h"
#import "ImageUtil.h"

@implementation GAZIRUSearchLogic

-(void)executeGAZIRUSearch:(CMSampleBufferRef)sampleBuffer
{
    // Create UIImage from buffer
    UIImage *image = [ImageUtil getUIImageFromSampleBuffer:sampleBuffer];
    
    // Create resized UIImage
    _queryImage = [ImageUtil imageResize:image];
    
    int width = CGImageGetWidth(_queryImage.CGImage);
    int height = CGImageGetHeight(_queryImage.CGImage);
    NSLog(@"Resized image width[%d], height[%d]", width, height);
    
    NSString *featureFilePath;
    NSString *appendFilePath;
    int imageSearchMode = SERVER_SERVICE_SEARCH;
    
    if (imageSearchMode == CLIENT_SEARCH) {
        // client search mode do not need the extra info
        featureFilePath = [[NSBundle mainBundle] pathForResource:@"FeatureDB.dic" ofType:nil];
        appendFilePath = [[NSBundle mainBundle] pathForResource:@"AppendInfoFile.info" ofType:nil];
    }
    
    RTSearchApi *rtSearchApi = [[RTSearchApi alloc] init];
    
    /************* Create Instance API ****************/
    RTFeatureSearcher *rtsearchlib = [rtSearchApi GetInstance:featureFilePath
                                                    withWidth:width
                                                   withHeight:height
                                                addAppendFile:appendFilePath];
    
    //if create instance failed, set error and write log.
    if (rtsearchlib == nil) {
        NSLog(@"GetInstance error...");
        return;
    }
    
    /************* Image Search API ****************/
    //for calculation operation time
    NSDate *startTime = [NSDate date];
    _resultArray = [rtsearchlib ExecuteSearchFromUIImage:_queryImage searchEnv:SERVER_SERVICE_SEARCH];
    
    // move to CameraViewController#handleGAZIRUSearchResult
    //    NSString *brand_slug = nil;
    //
    //    //if search failed, set error.
    //    if (resultArray == nil) {
    //        NSLog(@"Failed ExecuteSearch");
    //        //result count was 0
    //        brand_slug = @"failure";
    //
    //    } else if ([resultArray count] == 0) {
    //        NSLog(@"result count is 0. Don't HIT...");
    //        //result count was over 0
    //        brand_slug = @"failure";
    //    } else {
    //        NSDictionary *bland_dict = (NSDictionary *)[resultArray objectAtIndex: 0];
    //        NSMutableArray *appendedInfos = (NSMutableArray *)[ bland_dict valueForKey:@"appendInfo"];
    //        brand_slug = [ appendedInfos objectAtIndex:0];
    //        DLog(@"BRAND SLUG - %@", brand_slug);
    //    }
    
    //for calculation operation time
    NSDate *stopTime = [NSDate date];
    NSTimeInterval operationTime = [stopTime timeIntervalSinceDate:startTime];
    NSLog(@"executeApi Operation Time is %f", operationTime);
    
    [rtsearchlib CloseFeatureSearcher];
}
@end
