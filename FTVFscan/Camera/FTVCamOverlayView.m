//
//  EIJUSCamOverlayView.m
//  FleaMarket
//
//  Created by Alsor Zhou on 12-4-13.
//  Copyright (c) 2012年 EIJUS. All rights reserved.
//

#import "FTVCamOverlayView.h"
//#import "UIDevice+IdentifierAddition.h"

static const CGFloat kItemLeftPedding       =   10.0;
static const CGFloat kItemTopPedding        =   30.0;
static const CGFloat kItemBgWidth           =   282;
static const CGFloat kItemBgHeight          =   220;
static const CGFloat kItemWidth             =   280;
static const CGFloat kItemHeight            =   218;

static const CGFloat kItemBgLeftPedding     =   1.0;
static const CGFloat kItemBgTopPedding      =   1.0;
static const NSUInteger kTagPublishBtn      =   10001;
static const NSUInteger kGuideMoveArround   =   1008;

@implementation FTVCamOverlayView
@synthesize delegate;

#pragma mark -
#pragma mark Delegate Method
- (void)retake
{
    if ([delegate respondsToSelector:@selector(retake)]) {
        [delegate retake];
    }
}

- (void)delayJob
{
    [self performSelectorOnMainThread:@selector(retake) withObject:NULL waitUntilDone:YES];
}

- (void)startPublish
{

}

static const CGFloat imageWidth = 720;
static const CGFloat imageHeight = 540;

- (id)initWithFrame:(CGRect)frame image:(NSString*)_imagePath
{
    self = [super initWithFrame:frame];
    if (self) {        
        // Initialization code        
        self.backgroundColor = [UIColor clearColor];

        imagePath = [_imagePath copy];
        
        UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 460.0)];
        
        bgView = [[UIView alloc] initWithFrame:CGRectMake((320 - kItemBgWidth)/2.0 + 1.0, 30.0, kItemBgWidth, kItemBgHeight)];
        bgView.backgroundColor = [UIColor whiteColor];
        [content addSubview:bgView];
        
        imageView = [[EAGLView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
        [imageView setCenter:CGPointMake((320 - kItemWidth)/2.0 + kItemBgLeftPedding + kItemWidth / 2, 30.0 + kItemBgTopPedding + kItemHeight / 2)];
        imageView.transform = CGAffineTransformMakeScale(kItemWidth / imageWidth, kItemHeight / imageHeight);
        imageView.userInteractionEnabled = YES;
        [imageView prepareGLEnv:[imagePath copy]];
        [content addSubview:imageView];
        
        [self addSubview:content];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{   
    CGPoint tappedPt = [[touches anyObject] locationInView: self];
    lastOffset = tappedPt;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint tappedPt = [[touches anyObject] locationInView: self];
    
    if (fabs(tappedPt.x - lastOffset.x) > fabs(tappedPt.y - lastOffset.y)) {
        // brightness
        imageView.modeA = 0;
        imageView.valueA = tappedPt.x / imageView.frame.size.width + 0.5;
        [imageView drawView];
    } else {
        // saturation
        imageView.mode = 2;
        imageView.value = tappedPt.y / imageView.frame.size.height + 0.5;
        [imageView drawView];
    }

    lastOffset = tappedPt;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *guide = [self viewWithTag:kGuideMoveArround];
    if (guide) {
        [UIView animateWithDuration:1.0 animations:^{
            guide.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (![guide isKindOfClass:[NSNull class]] && guide != NULL) {
                [guide removeFromSuperview];
            }
        }];
    }       

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *guide = [self viewWithTag:kGuideMoveArround];
    if (guide) {
        [UIView animateWithDuration:1.0 animations:^{
            guide.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (![guide isKindOfClass:[NSNull class]] && guide != NULL) {
                [guide removeFromSuperview];
            }
        }];
    }       

    [self endEditing:YES];
}
@end
