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


+ (NSString*)executeApi:(UIImage*)image;

+ (void)postWithBrand:(NSString *)brandSlug
       withStartBlock:(void (^)(void))startBlock
      withFinishBlock:(void (^)(BOOL success, NSString *resp))finishBlock
      withFailedBlock:(void (^)(BOOL success, NSString *resp))failedBlock;

+ (void)postData:(NSData *)photoData
       withBrand:(NSString *)brandSlug
          withId:(NSString *)idStr
  withStartBlock:(void (^)(void))startBlock
 withFinishBlock:(void (^)(BOOL success, NSString *resp))finishBlock
 withFailedBlock:(void (^)(BOOL success, NSString *resp))failedBlock;

+ (NSString*)encapsulateById:(NSString*)id;

+ (void)openSafari:(NSString *)urlString;
@end
