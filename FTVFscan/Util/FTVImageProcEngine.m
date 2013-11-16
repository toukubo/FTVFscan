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
 * 2. proc engine resize the images by ratio, WIDTH must be multiple of 4, and width/height ratio must be kept as original.
 * 3. store the processed image to photo album
 * 4. post the processed image to remote
 */
@implementation FTVImageProcEngine

+ (UIImage*)imageResize:(UIImage*)srcImage
{
    // workaround : we used a very never met height, so it will always constraint by the width.
    return [srcImage resizedImageToFitInSize:CGSizeMake(496, 9999) scaleIfSmaller:YES];
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
+ (NSString*)executeApi:(UIImage*)image
{
    //    UIImage *image = [UIImage imageNamed:@"NEC_new.jpg"];
    int width = CGImageGetWidth(image.CGImage);
    int height = CGImageGetHeight(image.CGImage);
    
    /************* Create API Instance ****************/
    RTSearchApi *api = [[RTSearchApi alloc] init];
    
    /************* Execute Authentication API ****************/
    NSString *authResult = [api RTSearchAuth];
    NSLog(@"authResult = %@", authResult);
    
    //if authentication succeeded, execute search.
    if ([authResult isEqualToString:AUTH_OK]) {
        NSString *featureFilePath;
        NSString *appendFilePath;
        int imageSearchMode = SERVER_SERVICE_SEARCH;
        
        if (imageSearchMode == CLIENT_SEARCH) {
            // client search mode do not need the extra info
            featureFilePath = [[NSBundle mainBundle] pathForResource:@"FeatureDB.dic" ofType:nil];
            appendFilePath = [[NSBundle mainBundle] pathForResource:@"AppendInfoFile.info" ofType:nil];
        }
        
        /************* Create Instance API ****************/
        RTFeatureSearcher *rtsearchlib = [api GetInstance:featureFilePath
                                                withWidth:width
                                               withHeight:height
                                            addAppendFile:appendFilePath];
        
        //if create instance failed, set error and write log.
        if (rtsearchlib == nil) {
            NSLog(@"GetInstance error...");
            return nil;
        }
        
        /************* Image Search API ****************/
        //for calculation operation time
        NSDate *startTime = [NSDate date];
        
        NSMutableArray *resultArray = [rtsearchlib ExecuteSearchFromUIImage:image searchEnv:SERVER_SERVICE_SEARCH];
        NSLog(@"resultArray = %@", resultArray);
        
        NSString *brand_slug = nil;
        
        //if search failed, set error.
        if (resultArray == nil) {
            NSLog(@"Failed ExecuteSearch");
            //result count was 0
            brand_slug = @"failure";
            
        } else if ([resultArray count] == 0) {
            NSLog(@"result count is 0. Don't HIT...");
            //result count was over 0
            brand_slug = @"failure";
        } else {
            NSDictionary *bland_dict = (NSDictionary *)[resultArray objectAtIndex: 0];
            NSMutableArray *appendedInfos = (NSMutableArray *)[ bland_dict valueForKey:@"appendInfo"];
            brand_slug = [ appendedInfos objectAtIndex:0];
            DLog(@"BRAND SLUG - %@", brand_slug);
        }
        
        //for calculation operation time
        NSDate *stopTime = [NSDate date];
        NSTimeInterval operationTime = [stopTime timeIntervalSinceDate:startTime];
        NSLog(@"Operation Time is %f", operationTime);
        
        /************* Terminate API ****************/
        [rtsearchlib CloseFeatureSearcher];
        
        return brand_slug;
    } else {
        // handle following errors
        //            #define AUTH_CONST_ERROR    @"0101"
        //            #define AUTH_OPE_ERROR      @"0201"
        //            #define AUTH_SRV_ERROR      @"0501"
        //            #define AUTH_CON_ERROR      @"0901"
    }
    return nil;
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

+ (NSString*)encapsulateById:(NSString*)id
{
    return [NSString stringWithFormat:@"%@%@%@%@%@", BASEURL, @"/scan/scan.php?deviceid=", [FTVUser getId], @"&id=", id];
}

+ (void)openSafari:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url != nil && ![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}
@end
