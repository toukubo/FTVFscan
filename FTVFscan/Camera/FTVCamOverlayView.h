//
//  EIJUSCamOverlayView.h
//  FleaMarket
//
//  Created by Alsor Zhou on 12-4-13.
//  Copyright (c) 2012年 EIJUS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAGLView.h"

@class ASIFormDataRequest;

@protocol FTVCamOverlayViewDelegate <NSObject>
@optional
- (void)retake;
@end

@interface FTVCamOverlayView : UIView
{   
    CGPoint                     lastOffset;
    
    UIView                      *bgView;
    
    CGPoint                     oldCenter;
    
    EAGLView                    *imageView;
    NSString                    *imagePath;
    ASIFormDataRequest          *request;
}

@property (nonatomic, assign) id delegate;

- (id)initWithFrame:(CGRect)frame image:(NSString*)imagePath;
@end
