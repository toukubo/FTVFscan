//
//  FTVImageProcEngine.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-10-30.
//  Copyright (c) 2013年 T2. All rights reserved.
//
#import <RTSearchKit/RTSearchApi.h>
#import <RTSearchKit/RTFeatureSearcher.h>

#import <ASIFormDataRequest.h>

#import "FTVImageProcEngine.h"
#import "FTVImageProcOption.h"

/**
 * FTVImageProcEngine is used to process images after pick from camera or photo gallery.
 *
 * workflow - 
 * 1. user select images from camera/gallery
 * 2. proc engine resize the images by ratio, constraint with CGSize(500, 500)
 * 3. store the processed image to photo album
 * 4. post the processed image to remote
 *
 * Currently, it only support resize to W500xH500 px.
 */
@implementation FTVImageProcEngine

+ (UIImage*)imageResize:(UIImage*)srcImage
{
    return [srcImage resizedImageToFitInSize:CGSizeMake(500, 500) scaleIfSmaller:YES];
}

+ (UIImage*)imageResize:(UIImage*)srcImage saveWithName:(NSString*)imgName usingJPEG:(BOOL)jpeg
{
    UIImage *image = [FTVImageProcEngine imageResize:srcImage];
    
    NSString *savedImagePath = [PathForDocumentsResource(@"") stringByAppendingPathComponent:imgName];
    
    NSData *imageData;
    
    if (jpeg) {
        imageData = UIImageJPEGRepresentation(image, .5);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }
    
    [imageData writeToFile:savedImagePath atomically:NO];
    
    return image;
}


// ------------- NEC Image Search Function ----------------
// stolen from RTSearchApiTester
+ (void)executeApi:(UIImage*)image
{
    /** Error **/
    NSString *error;
    
//    UIImage *image = [UIImage imageNamed:@"NEC_new.jpg"];
    
    int width = CGImageGetWidth(image.CGImage);
    int height = CGImageGetHeight(image.CGImage);
    
    //
    /************* Create API Instance ****************/
    RTSearchApi *api = [[RTSearchApi alloc] init];
    
    /************* Execute Authentication API ****************/
    NSString *authResult = [api RTSearchAuth];
    NSLog(@"authResult = %@", authResult);
    
    //if authentication succeeded, execute search.
    if ([authResult isEqualToString:@"0000"]) {
        NSString *featureFilePath = [[NSBundle mainBundle] pathForResource:@"FeatureDB.dic" ofType:nil];

        NSString *appendFilePath = [[NSBundle mainBundle] pathForResource:@"AppendInfoFile.info" ofType:nil];
        
        
        /************* Create Instance API ****************/
        RTFeatureSearcher *rtsearchlib = [api GetInstance:featureFilePath
                                                withWidth:width
                                               withHeight:height
                                            addAppendFile:appendFilePath];
        
        //if create instance failed, set error and write log.
        if (rtsearchlib == nil) {
            error = @"GetInstance error...";
            NSLog(@"GetInstance error...");
            return;
        }
        
        /************* Image Search API ****************/
        //for calculation operation time
        NSDate *startTime = [NSDate date];
        //NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        
        NSMutableArray *resultArray = [rtsearchlib ExecuteSearchFromUIImage:image searchEnv:SERVER_SERVICE_SEARCH];
        NSLog(@"resultArray = %@", resultArray);
        
        //if search failed, set error.
        if (resultArray == nil) {
            error = @"Failed ExecuteSearch";
            NSLog(@"Failed ExecuteSearch");
            //result count was 0
        } else if ([resultArray count] == 0) {
            error = @"result count is 0. Don't HIT...";
            NSLog(@"result count is 0. Don't HIT...");
            
            //result count was over 0
        } else {
            error = nil;
        }
        
        //for calculation operation time
        NSDate *stopTime = [NSDate date];
        NSTimeInterval operationTime = [stopTime timeIntervalSinceDate:startTime];
        NSLog(@"Operation Time is %f", operationTime);
        
        /************* Terminate API ****************/
        [rtsearchlib CloseFeatureSearcher];
        
    } else {
        error = @"Non. Authentication Failed.";
    }
}

+ (void)postData:(NSData *)photoData
       withBrand:(NSString *)brandSlug
  withStartBlock:(void (^)(void))startBlock
 withFinishBlock:(void (^)(BOOL success, NSString *resp))finishBlock
 withFailedBlock:(void (^)(BOOL success, NSString *resp))failedBlock

{
    __weak NSString *urlStr = [NSString stringWithFormat:@"%@%@", BASEURL, @"scan/post.php"];
    __weak ASIFormDataRequest* req = [ASIFormDataRequest
                               requestWithURL:[NSURL URLWithString:urlStr]];
    [req setTimeOutSeconds:120];
    [req addPostValue:[FTVUser getId] forKey:@"user_id"];
    [req addPostValue:brandSlug forKey:@"brand_slug"];
    
    [req setData:photoData withFileName:@"image.png" andContentType:@"image/png" forKey:@"image"];

    req.defaultResponseEncoding = NSUTF8StringEncoding;
    
    [req setCompletionBlock:^{
        if (req.responseStatusCode == 200) {
            NSString* resString = [req responseString];
            [FTVImageProcEngine openSafari:resString];
            finishBlock(YES, req.responseString);
        } else {
            failedBlock(NO, req.responseString);
        }
    }];
    
    [req setFailedBlock:^{
        failedBlock(NO, req.responseString);
    }];
    
    // TODO: show progress or something...
//    [req setUploadSizeIncrementedBlock:^(long long size) {
//
//    }];
    
    [req startAsynchronous];
}

+ (void)openSafari:(NSString *)id
{
    NSString *req_url = [NSString stringWithFormat:@"%@%@%@%@%@", BASEURL,@"/scan/scan.php?deviceid=",[FTVUser getId],@"&id=",id];
    NSURL *url = [NSURL URLWithString:req_url];
    
    if (url != nil && ![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}
@end
