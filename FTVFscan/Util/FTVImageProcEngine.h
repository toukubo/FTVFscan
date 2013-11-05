//
//  FTVImageProcEngine.h
//  FTVFscan
//
//  Created by Alsor Zhou on 13-10-30.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTVImageProcEngine : NSObject

+ (UIImage*)imageResize:(UIImage*)srcImage;

+ (UIImage*)imageResize:(UIImage*)srcImage saveWithName:(NSString*)imgName usingJPEG:(BOOL)jpeg;


+ (void)executeApi:(UIImage*)image;

+ (void)postData:(NSData *)photoData
       withBrand:(NSString *)brand_slug
  withStartBlock:(void (^)(void))startBlock
 withFinishBlock:(void (^)(BOOL success, NSString *resp))finishBlock
 withFailedBlock:(void (^)(BOOL success, NSString *resp))failedBlock;
@end
