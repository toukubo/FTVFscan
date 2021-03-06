//
//  ScanDetailView.m
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/20.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <RTSearchKit/RTFeatureSearcher.h>
#import "ScanDetailView.h"

@implementation ScanDetailView

/**
 スキャン結果表示領域部品初期化処理<BR>
 スキャン結果表示領域に定義されている各部品を初期化する処理です。<BR>
 */
-(void)initComponent
{
    // 付加情報表示領域に文字列初期化
    //[_appendInfo1Label setText:NSLocalizedString(@"label_camera_result_defalt", @"")];
    [_appendInfo2Label setText:@""];
    // クエリ画像解放
    _queryImage = nil;
    // スキャン失敗・ヒット無し状態で初期化
    _isScanHit = NO;
    // ボタン有効化
    [_detailButton setEnabled:YES];
    dotUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateDotProgress:)
     userInfo:nil
     repeats:YES];
}

- (void)updateDotProgress:(NSTimer *)updatedTimer
{
    CGRect imgFrm = [_dotImg frame];
    
    if (imgFrm.origin.x >= 112)
    {
        imgFrm.origin.x = 12;
    }
    else
    {
        imgFrm.origin.x += 10;
    }
    [_dotImg setFrame:imgFrm];
}

/**
 スキャン結果表示処理<BR>
 引数のスキャン結果を領域に表示する処理です。
 @param searchResult GAZIRU検索結果
 @param queryImage GAZIRU検索クエリ画像
 */
-(void)showScanDetail:(NSMutableArray *)searchResult withQueryImage:(UIImage *)queryImage
{
    // スキャン失敗・ヒット無し状態で初期化
    _isScanHit = NO;
    
    // クエリ画像を保持
    _queryImage = queryImage;
    brand_slug = @"";
    
    // GAZIRU検索失敗の場合
    if (searchResult == nil) {
        // GAZIRU検索失敗を表示する
        
        //[_appendInfo1Label setText:NSLocalizedString(@"label_camera_result_connection_failed", @"")];
        if (dotUpdateTimer == nil)
        {
            dotUpdateTimer =
            [NSTimer
             scheduledTimerWithTimeInterval:0.1
             target:self
             selector:@selector(updateDotProgress:)
             userInfo:nil
             repeats:YES];
            _dotImg.hidden = NO;
            _endsymImg.hidden = YES;
        }
        [_appendInfo1Label setText:@""];
        [_appendInfo2Label setText:@""];
    }
    // GAZIRU検索ヒット無しの場合
    else if ([searchResult count] <= 0) {
        if (dotUpdateTimer == nil)
        {
            dotUpdateTimer =
            [NSTimer
             scheduledTimerWithTimeInterval:0.1
             target:self
             selector:@selector(updateDotProgress:)
             userInfo:nil
             repeats:YES];
            _dotImg.hidden = NO;
            _endsymImg.hidden = YES;
        }
        // 再スキャンメッセージを表示する
        //[_appendInfo1Label setText:NSLocalizedString(@"label_camera_result_defalt", @"")];
        [_appendInfo1Label setText:@""];
        [_appendInfo2Label setText:@""];
    }
    // GAZIRU検索ヒットした場合
    else {
        // スキャンヒット状態に更新
        _isScanHit = YES;
        
        // スキャン結果をスコア降順ソートする
        NSSortDescriptor *descSortDescriptor = [[NSSortDescriptor alloc] initWithKey:COLUMN_KEY_SCORE ascending:NO];
        NSArray *sortDescArray = [searchResult sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descSortDescriptor, nil]];
        
        // トップスコアのスキャン結果を取得する
        NSArray *displayResult = [[sortDescArray objectAtIndex:0] objectForKey:COLUMN_KEY_APPENDINFO];
        
        if (dotUpdateTimer)
        {
            [dotUpdateTimer invalidate];
            dotUpdateTimer = nil;
        }
        _dotImg.hidden = YES;
        _endsymImg.hidden = NO;

        // スキャン結果のラベル表示する
        [_appendInfo1Label setText:[NSString stringWithFormat:@"%@",
                                    [displayResult objectAtIndex:1]]];
        brand_slug = [displayResult objectAtIndex:0];
        recognitionId = [NSString stringWithFormat:@"%@", [[sortDescArray objectAtIndex:0] objectForKey:COLUMN_KEY_ID]];
        
        
//        [_appendInfo2Label setText:[NSString stringWithFormat:@"%@",
//                                    [displayResult objectAtIndex:1]]];
        [_appendInfo2Label setText:@""];
        
        NSLog(@"Result 1 :----- %@", [displayResult objectAtIndex:0]);
        NSLog(@"Result 2 :----- %@", [displayResult objectAtIndex:1]);
    }
}

- (void)dealloc
{
	if (dotUpdateTimer)
	{
		[dotUpdateTimer invalidate];
		dotUpdateTimer = nil;
	}
}

@end
