//
//  RTSearchApi.h
//  rtsearchlib
//  画像識別ライブラリAPI提供クラス
//  Copyright (c) 2012年 NECソフト(株). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTFeatureSearcher.h"

#define AUTH_OK             @"0000"
#define AUTH_CONST_ERROR    @"0101"
#define AUTH_OPE_ERROR      @"0201"
#define AUTH_SRV_ERROR      @"0501"
#define AUTH_CON_ERROR      @"0901"

@interface RTSearchApi : NSObject

{
    
}


//企業認証処理実行メソッド
- (NSString*) RTSearchAuth;

//識別API実行用インスタンス取得メソッド
- (RTFeatureSearcher*) GetInstance:(NSString*)featureFilePath
                         withWidth:(int)width
                         withHeight:(int)height
                     addAppendFile:(NSString*)appendFile;

@end
