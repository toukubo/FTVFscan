//
//  rtsearchlib.h
//  rtsearchlib
//
//  Created by Takahiro Shida on 12/07/18.
//  Copyright (c) 2012年 NECソフト(株). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

//****************** サーバ検索実行環境切替用key ******************//
#define CLIENT_SEARCH               0   // クライアント端末での検索
#define SERVER_SERVICE_SEARCH       1   // サーバ（サービス環境）での検索
#define SERVER_STAGING_SEARCH       2   // サーバ（ステージング環境）での検索

//*************** 付加情報取得用 NSDictionary Key ***************//
//付加情報ファイルカラムkey文字列
#define COLUMN_KEY_ID               @"id"
#define COLUMN_KEY_WIDTH            @"append_dic_width"
#define COLUMN_KEY_HEIGHT           @"append_dic_height"
#define COLUMN_KEY_APPENDINFO       @"appendInfo"

//返却情報に追加するkey文字列
#define COLUMN_KEY_SCORE            @"score"
#define COLUMN_KEY_CENTERCOOD_X     @"centerCoordX"
#define COLUMN_KEY_CENTERCOOD_Y     @"centerCoordY"
#define COLUMN_KEY_UPLEFTCOOD_X     @"upLeftCoordX"
#define COLUMN_KEY_UPLEFTCOOD_Y     @"upLeftCoordY"
#define COLUMN_KEY_LOWLEFTCOOD_X    @"lowLeftCoordX"
#define COLUMN_KEY_LOWLEFTCOOD_Y    @"lowLeftCoordY"
#define COLUMN_KEY_UPRIGHTCOOD_X    @"upRightCoordX"
#define COLUMN_KEY_UPRIGHTCOOD_Y    @"upRightCoordY"
#define COLUMN_KEY_LOWRIGHTCOOD_X   @"lowRightCoordX"
#define COLUMN_KEY_LOWRIGHTCOOD_Y   @"lowRightCoordY"
//*************************************************************//

@interface RTFeatureSearcher : NSObject
    <AVCaptureVideoDataOutputSampleBufferDelegate,NSStreamDelegate>

{
    
}

//指定イニシャライザ(RTSearchApiから引数等を受け取る)
- (id) initWithUserParameter:(NSString*)iniFilePath
                   withWidth:(int)width
                  withHeight:(int)height
               addAppendFile:(NSString*)appendFile;

//識別API－CMSampleBufferRefからの識別
- (NSMutableArray*)ExecuteSearchFromSampleBuffer:(CMSampleBufferRef)imgBuffer
                                       searchEnv:(int)searchEnv;

//識別API－UIImageからの識別
- (NSMutableArray*)ExecuteSearchFromUIImage:(UIImage*)imgBuffer
                                  searchEnv:(int)searchEnv;

//終了API
- (int) CloseFeatureSearcher;

@end
