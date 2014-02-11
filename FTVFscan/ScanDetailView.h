//
//  ScanDetailView.h
//  f.scan Sample
//
//  Created by GAZIRU Developer on 2014/01/20.
//  Copyright (c) NEC Soft, Ltd. 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanDetailView : UIView
{
    NSTimer *dotUpdateTimer;
    @public
    NSString *brand_slug;
}

@property (strong, nonatomic) IBOutlet UIButton *detailButton;       // 詳細領域ボタン
@property (strong, nonatomic) IBOutlet UILabel *appendInfo1Label;   // 付加情報１表示領域
@property (strong, nonatomic) IBOutlet UILabel *appendInfo2Label;   // 付加情報２表示領域
@property (strong, nonatomic) UIImage *queryImage;                  // クエリ画像
@property (strong, nonatomic) IBOutlet UIImageView *dotImg;
@property (nonatomic) BOOL isScanHit;                               // スキャンヒットフラグ（ヒット表示中／失敗・ヒット無し表示中）

-(void)initComponent;
-(void)showScanDetail:(NSMutableArray *)searchResult withQueryImage:(UIImage *)queryImage;
- (void)updateDotProgress:(NSTimer *)aNotification;
@end
