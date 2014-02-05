//
//  MSNavigationPaneViewController.h
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 9/4/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MSNavigationPaneViewController.h"
#import "PRTween.h"
#import <QuartzCore/QuartzCore.h>

//#define LAYOUT_DEBUG

// Sizes
const CGFloat MSNavigationPaneDefaultOpenStateRevealWidthLeft = 267.0;
const CGFloat MSNavigationPaneDefaultOpenStateRevealWidthTop = 200.0;
const CGFloat MSNavigationPaneOpenAnimationOvershot = 20.0;

// Appearance Type Constants
const CGFloat MSNavigationPaneAppearanceTypeZoomScaleFraction = 0.075;
const CGFloat MSNavigationPaneAppearanceTypeParallaxOffsetFraction = 0.35;

// Animation Durations
const CGFloat MSNavigationPaneAnimationDurationOpenToSide = 0.2;
const CGFloat MSNavigationPaneAnimationDurationClosedToSide = 0.5;
const CGFloat MSNavigationPaneAnimationDurationSideToClosed = 0.45;
const CGFloat MSNavigationPaneAnimationDurationOpenToClosed = 0.3;
const CGFloat MSNavigationPaneAnimationDurationClosedToOpen = 0.3;
const CGFloat MSNavigationPaneAnimationDurationSnap = 0.2;

// Velocity Thresholds
const CGFloat MSDraggableViewVelocityThreshold = 5.0;

typedef void (^ViewActionBlock)(UIView *view);

@interface UIView (ViewHierarchyAction)

- (void)superviewHierarchyAction:(ViewActionBlock)viewAction;

@end

@implementation UIView (ViewHierarchyAction)

- (void)superviewHierarchyAction:(ViewActionBlock)viewAction
{
    viewAction(self);
    [self.superview superviewHierarchyAction:viewAction];
}

@end

@interface MSNavigationPaneViewController () <UIGestureRecognizerDelegate> {
    
    UIViewController *_masterViewController;
    UIViewController *_paneViewController;
    MSNavigationPaneAppearanceType _appearanceType;
    MSNavigationPaneState _paneState;
    MSNavigationPaneOpenDirection _openDirection;
}

@property (nonatomic, assign) BOOL animatingPane;
@property (nonatomic, assign) BOOL animatingRotation;
@property (nonatomic, assign) CGPoint paneStartLocation;
@property (nonatomic, assign) CGPoint paneStartLocationInSuperview;
@property (nonatomic, assign) CGFloat paneVelocity;

@property (nonatomic, strong) UIPanGestureRecognizer *panePanGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *paneTapGestureRecognizer;

- (void)initialize;
- (void)animatePaneToState:(MSNavigationPaneState)state duration:(CGFloat)duration bounce:(BOOL)bounce;
- (void)updateAppearance;
- (CGFloat)paneViewClosedFraction;
- (void)paneTapped:(UIPanGestureRecognizer *)gesureRecognizer;
- (void)panePanned:(UITapGestureRecognizer *)gesureRecognizer;

@end

@implementation MSNavigationPaneViewController

@dynamic masterViewController;
@dynamic paneViewController;
@dynamic paneState;
@dynamic appearanceType;

#pragma mark - NSObject

- (void)dealloc
{
    [self.paneView removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // This prevents weird transform issues, set the transform to identity for the duration of the rotation, disables updates during rotation
    self.animatingRotation = YES;
    self.masterView.transform = CGAffineTransformIdentity;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // This prevents weird transform issues, set the transform to identity for the duration of the rotation, disables updates during rotation
    self.animatingRotation = NO;
    [self updateAppearance];
}

#pragma mark - MSNavigationPaneViewController

- (void)initialize
{
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    // MSNavigationPaneAppearanceTypeParallaxモードでコンテナビュー外の領域にサブビューとしてmasterViewを配置する。
    // Navigation移動する際に、コンテナ外の領域が表示されてしまう（メニューが一瞬見える）ためコンテナ外領域は表示しない設定を行う。
    self.view.clipsToBounds = YES;
    // ペイン状態をクローズ状態で初期化
    _paneState = MSNavigationPaneStateClosed;
    
    _appearanceType = MSNavigationPaneAppearanceTypeParallax; // Parallaxモードで初期化
    _openDirection = MSNavigationPaneOpenDirectionRight; // 右アニメーションモードで初期化
    _openStateRevealWidth = MSNavigationPaneDefaultOpenStateRevealWidthLeft;
    _paneDraggingEnabled = YES;
    _paneViewSlideOffAnimationEnabled = YES;
    _paneViewShadowEnabled = NO; // ペインの影無効化で初期化
    
    _touchForwardingClasses = [NSMutableSet setWithObjects:UISlider.class, UISwitch.class, nil];
    
    _masterView = [[UIView alloc] initWithFrame:self.view.bounds];
    _masterView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _masterView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_masterView];
    
    _paneView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.paneView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.paneView.backgroundColor = [UIColor clearColor];

    // ペインの影指定が有効な場合のみ影指定する
    if (_paneViewShadowEnabled) {
        // Ensure that the shadow extends beyond the edges of the screen
        self.paneView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.paneView.frame, -40.0, 0.0)] CGPath];
        self.paneView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.paneView.layer.shadowOpacity = 1.0;
        self.paneView.layer.shadowRadius = 10.0;
        self.paneView.layer.masksToBounds = NO;
    }
    
    [self.view addSubview:self.paneView];
    
    [self.paneView addObserver:self forKeyPath:@"frame" options:NULL context:NULL];
    
    self.panePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panePanned:)];
    self.panePanGestureRecognizer.minimumNumberOfTouches = 1;
    self.panePanGestureRecognizer.maximumNumberOfTouches = 1;
    self.panePanGestureRecognizer.delegate = self;
    [self.paneView addGestureRecognizer:self.panePanGestureRecognizer];
    
#if defined(LAYOUT_DEBUG)
    _masterView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    _masterView.layer.borderColor = [[UIColor blueColor] CGColor];
    _masterView.layer.borderWidth = 2.0;
    
    self.paneView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    self.paneView.layer.borderColor = [[UIColor redColor] CGColor];
    self.paneView.layer.borderWidth = 2.0;
#endif
}

#pragma mark View Controller Accessors

- (UIViewController *)masterViewController
{
    return _masterViewController;
}

- (void)setMasterViewController:(UIViewController *)masterViewController
{
	if (self.masterViewController == nil) {
        
        masterViewController.view.frame = _masterView.bounds;
		_masterViewController = masterViewController;
		[self addChildViewController:self.masterViewController];
		[_masterView addSubview:self.masterViewController.view];
		[self.masterViewController didMoveToParentViewController:self];
        
	} else if (self.masterViewController != masterViewController) {
        
		masterViewController.view.frame = _masterView.bounds;
		[self.masterViewController willMoveToParentViewController:nil];
		[self addChildViewController:masterViewController];
        
        void(^transitionCompletion)(BOOL finished) = ^(BOOL finished) {
            [self.masterViewController removeFromParentViewController];
            [masterViewController didMoveToParentViewController:self];
            _masterViewController = masterViewController;
        };
        
		[self transitionFromViewController:self.masterViewController
						  toViewController:masterViewController
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:nil
								completion:transitionCompletion];
	}
}

- (UIViewController *)paneViewController
{
    return _paneViewController;
}

- (void)setPaneViewController:(UIViewController *)paneViewController
{
	if (self.paneViewController == nil) {
        
		paneViewController.view.frame = self.paneView.bounds;
		_paneViewController = paneViewController;
		[self addChildViewController:self.paneViewController];
		[self.paneView addSubview:self.paneViewController.view];
		[self.paneViewController didMoveToParentViewController:self];
        
	} else if (self.paneViewController != paneViewController) {
        
		paneViewController.view.frame = self.paneView.bounds;
		[self.paneViewController willMoveToParentViewController:nil];
		[self addChildViewController:paneViewController];
        
        void(^transitionCompletion)(BOOL finished) = ^(BOOL finished) {
            [self.paneViewController removeFromParentViewController];
            [paneViewController didMoveToParentViewController:self];
            _paneViewController = paneViewController;
        };
        
		[self transitionFromViewController:self.paneViewController
						  toViewController:paneViewController
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:nil
								completion:transitionCompletion];
	}
}

// 表示中のペインから引数のpaneViewControllerに切り替える処理
- (void)setPaneViewController:(UIViewController *)paneViewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    void(^internalCompletion)() = ^{
        self.view.userInteractionEnabled = YES;
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:didAnimateToPane:)]) {
            [self.delegate navigationPaneViewController:self didAnimateToPane:paneViewController];
        }
        if (completion != nil) completion();
    };
    
    if (!animated || (paneViewController == self.paneViewController) || (self.paneViewController == nil)) {
        self.paneViewController = paneViewController;
        internalCompletion();
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    // 現在表示中ペインとは別のペインを開く場合に経由する位置を指定するブロックメソッド
    // 現在位置〜movePaneToSide〜movePaneToClosedとアニメーションする
    // ※paneViewSlideOffAnimationEnabledが無効の場合には経由しない
    void(^movePaneToSide)() = ^{
        CGRect paneViewFrame = self.paneView.frame;
        switch (self.openDirection) {
            case MSNavigationPaneOpenDirectionLeft:
                paneViewFrame.origin.x = CGRectGetWidth(self.view.frame) + MSNavigationPaneOpenAnimationOvershot;
                break;
            case MSNavigationPaneOpenDirectionTop:
                paneViewFrame.origin.y = CGRectGetHeight(self.view.frame) + MSNavigationPaneOpenAnimationOvershot;
                break;
            case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
                // コンテナビューの幅＋オフセット分、画面の左側に移動する
                paneViewFrame.origin.x = - (CGRectGetWidth(self.view.frame) + MSNavigationPaneOpenAnimationOvershot);
                break;
        }
        self.paneView.frame = paneViewFrame;
    };
    
    void(^movePaneToClosed)() = ^{
        CGRect paneViewFrame = self.paneView.frame;
        paneViewFrame.origin = CGPointMake(0.0, 0.0);
        self.paneView.frame = paneViewFrame;
    };
    
    // If we're trying to animate to the currently visible pane view controller, just close
    if (paneViewController == self.paneViewController) {
        
        [UIView animateWithDuration:MSNavigationPaneAnimationDurationOpenToClosed
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:movePaneToClosed
                         completion:^(BOOL animationFinished) {
                             self.paneState = MSNavigationPaneStateClosed;
                             internalCompletion();
                         }];
    }
    // Otherwise, animate off to the right first, set the pane view controller, and then animate closed
    else {
        
        void(^newPaneCompletion)(BOOL finished) = ^(BOOL finished) {
            
            self.paneViewController = paneViewController;
            
            // Force redraw of the pane view (for smooth animation)
            [self.paneView setNeedsDisplay];
            [CATransaction flush];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Slide the pane back into view
                [UIView animateWithDuration:MSNavigationPaneAnimationDurationSideToClosed
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:movePaneToClosed
                                 completion:^(BOOL animationFinished) {
                                     if (animationFinished) {
                                         self.paneState = MSNavigationPaneStateClosed;
                                         internalCompletion();
                                     }
                                 }];
            });
        };
        
        CGFloat duration = 0.0;
        if (self.paneState == MSNavigationPaneStateOpen) {
            duration = MSNavigationPaneAnimationDurationOpenToSide;
        } else if (self.paneState == MSNavigationPaneStateClosed) {
            duration = MSNavigationPaneAnimationDurationClosedToSide;
        }
        
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:willAnimateToPane:)]) {
            [self.delegate navigationPaneViewController:self willAnimateToPane:paneViewController];
        }
        
        if (self.paneViewSlideOffAnimationEnabled) {
            [UIView animateWithDuration:duration
                             animations:movePaneToSide
                             completion:newPaneCompletion];
        } else {
            newPaneCompletion(YES);
        }
    }
}

#pragma mark Pane View Animation
// ペインが隠れている割合を取得する処理
- (CGFloat)paneViewClosedFraction
{
    CGFloat fraction;
    switch (self.openDirection) {
        case MSNavigationPaneOpenDirectionLeft:
            fraction = ((self.openStateRevealWidth - self.paneView.frame.origin.x) / self.openStateRevealWidth);
            break;
        case MSNavigationPaneOpenDirectionTop:
            fraction = ((self.openStateRevealWidth - self.paneView.frame.origin.y) / self.openStateRevealWidth);
            break;
        case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
            // openStateRevealWidthを100%として、どの程度の割合でペインが隠れているかを計算
            fraction = ((self.openStateRevealWidth + self.paneView.frame.origin.x) / self.openStateRevealWidth);
            break;
    }
    
    // Clip to 0.0 < fraction < 1.0
    fraction = (fraction < 0.0) ? 0.0 : fraction;
    fraction = (fraction > 1.0) ? 1.0 : fraction;
    
    return fraction;
}

// メニュー表示を更新する処理
- (void)updateAppearance
{
    CGFloat fraction = [self paneViewClosedFraction];
    
    // This prevents weird transform issues
    if (self.animatingRotation) {
        return;
    }
    
    if (self.appearanceType == MSNavigationPaneAppearanceTypeZoom) {
        CGFloat scale = (1.0 - (fraction * MSNavigationPaneAppearanceTypeZoomScaleFraction));
        self.masterView.transform = CGAffineTransformMakeScale(scale, scale);
    }
    else if (self.appearanceType == MSNavigationPaneAppearanceTypeParallax) {
        // ペインのクローズアニメーションしている位置に応じて、メニューの移動位置を計算する
        CGFloat translate = -((self.openStateRevealWidth * fraction) * MSNavigationPaneAppearanceTypeParallaxOffsetFraction);
        CGAffineTransform transform;
        switch (self.openDirection) {
            case MSNavigationPaneOpenDirectionLeft:
                transform = CGAffineTransformMakeTranslation(translate, 0.0);
                break;
            case MSNavigationPaneOpenDirectionTop:
                transform = CGAffineTransformMakeTranslation(0.0, translate);
                break;
            case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
                // 右から左にアニメーションさせる
                // ※呼ばれるたびに計算して位置更新してアニメーションする
                transform = CGAffineTransformMakeTranslation(-translate, 0.0);
                break;
        }
        self.masterView.transform = transform;
    }
    else if (self.appearanceType == MSNavigationPaneAppearanceTypeFade) {
        self.masterView.alpha = (1.0 - fraction);
    }
    
    // ペインの影設定が有効な場合のみ影指定する
    if (_paneViewShadowEnabled) {
        CGRect paneViewRect = (CGRect){CGPointZero, self.paneView.frame.size};
        switch (self.openDirection) {
            case MSNavigationPaneOpenDirectionLeft:
            case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
                // シャドウも描画更新する
                self.paneView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(paneViewRect, 0.0, -40.0)] CGPath];
                break;
            case MSNavigationPaneOpenDirectionTop:
                self.paneView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(paneViewRect, -40.0, 0.0)] CGPath];
                break;
        }
    }
}

// 引数の状態（Open/Close）にペインが遷移する際のアニメーション処理
- (void)animatePaneToState:(MSNavigationPaneState)state duration:(CGFloat)duration bounce:(BOOL)bounce
{
    // アニメーション開始位置
    CGFloat startPosition;
    switch (self.openDirection) {
        case MSNavigationPaneOpenDirectionLeft:
        case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
            // 開始位置は現在のx座標
            startPosition = self.paneView.frame.origin.x;
            break;
        case MSNavigationPaneOpenDirectionTop:
            startPosition = self.paneView.frame.origin.y;
            break;
    }
    
    // アニメーション終了位置
    CGFloat endPosition;
    switch (state) {
        case MSNavigationPaneStateOpen:
            switch (self.openDirection) {
                case MSNavigationPaneOpenDirectionLeft:
                case MSNavigationPaneOpenDirectionTop:
                    endPosition = self.openStateRevealWidth;
                    break;
                case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
                    // 終了位置は画面左にopenStateRevealWidthだけ移動した位置
                    endPosition = - self.openStateRevealWidth;
                    break;
            }
            break;
        case MSNavigationPaneStateClosed:
            endPosition = 0.0;
            break;
    }
    
    // アニメーション一更新が行われる場合にコールされるブロックメソッド
    void(^tweenUpdate)(PRTweenPeriod *period) = ^(PRTweenPeriod *period) {
        // ペインの現在位置を取得
        CGRect newFrame = self.paneView.frame;
        switch (self.openDirection) {
            case MSNavigationPaneOpenDirectionLeft:
                newFrame.origin = CGPointMake(period.tweenedValue, 0.0);
                break;
            case MSNavigationPaneOpenDirectionTop:
                newFrame.origin = CGPointMake(0.0, period.tweenedValue);
                break;
            case MSNavigationPaneOpenDirectionRight: // 右アニメーションの場合
                // x座標を通知された値で更新する
                newFrame.origin = CGPointMake(period.tweenedValue, 0.0);
                break;
        }
        // ペインの位置を更新
        self.paneView.frame = newFrame;
    };
    
    void(^tweenCompletion)() = ^() {
        self.animatingPane = NO;
        if (self.paneState != state) {
            self.paneState = state;
        }
    };
    
    self.animatingPane = YES;
    PRTweenPeriod *tweenPeriod = [PRTweenPeriod periodWithStartValue:startPosition endValue:endPosition duration:duration];
    PRTweenTimingFunction timingFunction = (bounce ? &PRTweenTimingFunctionBackOut : &PRTweenTimingFunctionQuadInOut);
    [[PRTween sharedInstance] addTweenPeriod:tweenPeriod updateBlock:tweenUpdate completionBlock:tweenCompletion timingFunction:timingFunction];
}

#pragma mark Appearance Type

- (void)setAppearanceType:(MSNavigationPaneAppearanceType)appearanceType
{
    // Reset scale transform if set to a new appearance type
    if (appearanceType != MSNavigationPaneAppearanceTypeZoom) {
        self.masterView.transform = CGAffineTransformIdentity;
    }
    // Reset translate transform if set to a new appearance type
    if (appearanceType != MSNavigationPaneAppearanceTypeParallax) {
        self.masterView.transform = CGAffineTransformIdentity;
    }
    if (appearanceType != MSNavigationPaneAppearanceTypeFade) {
        self.masterView.alpha = 1.0;
    }
    _appearanceType = appearanceType;
}

- (MSNavigationPaneAppearanceType)appearanceType
{
    return _appearanceType;
}

#pragma mark Pane State

- (MSNavigationPaneState)paneState
{
    return _paneState;
}

- (void)setPaneState:(MSNavigationPaneState)paneState
{
    [self setPaneState:paneState animated:NO completion:nil];
}

// ペイン状態（Open/Close）更新処理
- (void)setPaneState:(MSNavigationPaneState)paneState animated:(BOOL)animated completion:(void (^)(void))completion;
{
    void(^internalCompletion)() = ^ {
        _paneState = paneState;
        // Disable interation when pane is closed
        for (UIView *subview in self.paneView.subviews) {
            subview.userInteractionEnabled = (self.paneState == MSNavigationPaneStateClosed);
        }
        // Notify delegate of pane state change
        if ([self.delegate respondsToSelector:@selector(navigationPaneViewController:didUpdateToPaneState:)]) {
            [self.delegate navigationPaneViewController:self didUpdateToPaneState:self.paneState];
        }
        if (completion != nil) completion();
    };
    
    if (paneState == MSNavigationPaneStateClosed) {
        
        void(^animatePaneClosed)() = ^{
            CGRect paneViewFrame = self.paneView.frame;
            paneViewFrame.origin = CGPointMake(0.0, 0.0);
            self.paneView.frame = paneViewFrame;
        };
        
        void(^animatePaneClosedCompletion)(BOOL animationFinished) = ^(BOOL animationFinished) {
            internalCompletion();
            [self.paneView removeGestureRecognizer:self.paneTapGestureRecognizer];
        };
        
        if (animated) {
            [UIView animateWithDuration:MSNavigationPaneAnimationDurationClosedToOpen
                             animations:animatePaneClosed
                             completion:animatePaneClosedCompletion];
        } else {
            animatePaneClosed();
            animatePaneClosedCompletion(YES);
        }
        
    } else if (paneState == MSNavigationPaneStateOpen) { // Open状態に更新する場合
        
        void(^animatePaneOpen)() = ^{
            CGRect paneViewFrame = self.paneView.frame;
            switch (self.openDirection) {
                case MSNavigationPaneOpenDirectionLeft:
                    paneViewFrame.origin.x = self.openStateRevealWidth;
                    break;
                case MSNavigationPaneOpenDirectionTop:
                    paneViewFrame.origin.y = self.openStateRevealWidth;
                    break;
                case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
                    // ペインの表示位置をopenStateRevealWidthで指定した幅だけ左にずらす
                    paneViewFrame.origin.x = - self.openStateRevealWidth;
                    break;
            }
            self.paneView.frame = paneViewFrame;
        };
        
        void(^animatePaneOpenCompletion)(BOOL animationFinished) = ^(BOOL animationFinished) {
            internalCompletion();
            self.paneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paneTapped:)];
            self.paneTapGestureRecognizer.numberOfTouchesRequired = 1;
            self.paneTapGestureRecognizer.numberOfTapsRequired = 1;
            [self.paneView addGestureRecognizer:self.paneTapGestureRecognizer];
        };
        
        if (animated) {
            [UIView animateWithDuration:MSNavigationPaneAnimationDurationOpenToClosed
                             animations:animatePaneOpen
                             completion:animatePaneOpenCompletion];
        } else {
            animatePaneOpen();
            animatePaneOpenCompletion(YES);
        }
    }
}

#pragma mark Open Direction

- (MSNavigationPaneOpenDirection)openDirection
{
    return _openDirection;
}

- (void)setOpenDirection:(MSNavigationPaneOpenDirection)openDirection
{
    // Close the pane if it's currently open (before we update the direction)
    if (self.paneState == MSNavigationPaneStateOpen) {
        self.paneState = MSNavigationPaneStateClosed;
    }
    
    _openDirection = openDirection;
    
    // Reset the master view's transform when the open direction is changed
    self.masterView.transform = CGAffineTransformIdentity;
    [self updateAppearance];
}

#pragma mark - UIGestureRecognizer Callbacks

// ペインをタップした際のイベント
// ペインをクローズする
- (void)paneTapped:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self animatePaneToState:MSNavigationPaneStateClosed duration:MSNavigationPaneAnimationDurationOpenToClosed bounce:NO];
}

// ペインをパンした際のイベント
- (void)panePanned:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (!self.paneDraggingEnabled || self.animatingPane) {
        return;
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: { // パン操作開始イベントの場合
            // パン操作開始時のペインView内位置を保持し、加速度値を初期化する
            self.paneStartLocation = [gestureRecognizer locationInView:self.paneView];
            self.paneVelocity = 0.0;
            break;
        }
        case UIGestureRecognizerStateChanged: { // パン操作中イベントの場合
            // パン操作中のペインView内位置を保持する
            CGPoint panLocationInPaneView = [gestureRecognizer locationInView:self.paneView];
            // Pane Sliding
            CGRect newFrame = self.paneView.frame;
            switch (self.openDirection) {
                case MSNavigationPaneOpenDirectionLeft: {
                    newFrame.origin.x += (panLocationInPaneView.x - self.paneStartLocation.x);
                    if (newFrame.origin.x < 0.0) {
                        newFrame.origin.x = -nearbyintf(sqrtf(fabs(newFrame.origin.x) * 2.0));
                    } else if (newFrame.origin.x > self.openStateRevealWidth) {
                        newFrame.origin.x = (self.openStateRevealWidth + nearbyintf(sqrtf((newFrame.origin.x - self.openStateRevealWidth) * 2.0)));
                    }
                    self.paneView.frame = newFrame;
                    break;
                }
                case MSNavigationPaneOpenDirectionTop: {
                    newFrame.origin.y += (panLocationInPaneView.y - self.paneStartLocation.y);
                    if (newFrame.origin.y < 0.0) {
                        newFrame.origin.y = -nearbyintf(sqrtf(fabs(newFrame.origin.y) * 2.0));
                    } else if (newFrame.origin.y > self.openStateRevealWidth) {
                        newFrame.origin.y = (self.openStateRevealWidth + nearbyintf(sqrtf((newFrame.origin.y - self.openStateRevealWidth) * 2.0)));
                    }
                    self.paneView.frame = newFrame;
                    break;
                }
                case MSNavigationPaneOpenDirectionRight: { // 右アニメーションモードの場合
                    // パン操作後のx座標を更新
                    newFrame.origin.x += (panLocationInPaneView.x - self.paneStartLocation.x);
                    // 画面より右側にパン操作しようとしていた場合
                    if (newFrame.origin.x > 0.0) {
                        // 重みをつけて、徐々に右方向に移動できなくする
                        newFrame.origin.x = nearbyintf(sqrtf(fabs(newFrame.origin.x) * 2.0));
                    }
                    // openStateRevealWidthより左側にパン操作しようとしていた場合
                    else if (newFrame.origin.x < - self.openStateRevealWidth) {
                        // 重みをつけて、徐々に左方向に移動できなくする
                        newFrame.origin.x = (- self.openStateRevealWidth - nearbyintf(sqrtf((- newFrame.origin.x - self.openStateRevealWidth) * 2.0)));
                    }
                    // ペイン位置を補正後の座標に更新する
                    self.paneView.frame = newFrame;
                    break;
                }
            }
            // Velocity
            CGFloat velocity;
            switch (self.openDirection) {
                case MSNavigationPaneOpenDirectionLeft:
                case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
                    // パン操作開始位置からの相対x座標を保持する
                    velocity = -(self.paneStartLocation.x - panLocationInPaneView.x);
                    break;
                case MSNavigationPaneOpenDirectionTop:
                    velocity = -(self.paneStartLocation.y - panLocationInPaneView.y);
                    break;
            }
            // For some reason, velocity can be 0 due to an error in the API, so just ignore it
            if (velocity != 0) {
                self.paneVelocity = velocity;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: { // パン操作完了イベントの場合
            // We've reached the velocity threshold, bounce to the appropriate state
            if (fabsf(self.paneVelocity) > MSDraggableViewVelocityThreshold) { // 開始位置から閾値より操作した場合
                MSNavigationPaneState state;
                switch (self.openDirection) {
                    case MSNavigationPaneOpenDirectionLeft:
                    case MSNavigationPaneOpenDirectionTop:
                        state = ((self.paneVelocity > 0) ? MSNavigationPaneStateOpen : MSNavigationPaneStateClosed);
                        break;
                    case MSNavigationPaneOpenDirectionRight: // 右アニメーションモードの場合
                        // 左方向にパンしていた場合にはOpen, 右方向にパンしていた場合にはClose状態する
                        state = ((self.paneVelocity < 0) ? MSNavigationPaneStateOpen : MSNavigationPaneStateClosed);
                        break;
                }
                [self animatePaneToState:state duration:MSNavigationPaneAnimationDurationSnap bounce:YES];
            }
            // If we're released past half-way, snap to completion with no bounce, otherwise, snap to back to the starting position with no bounce
            else {
                MSNavigationPaneState state = (([self paneViewClosedFraction] > 0.5) ? MSNavigationPaneStateClosed : MSNavigationPaneStateOpen);
                [self animatePaneToState:state duration:MSNavigationPaneAnimationDurationSnap bounce:YES];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!self.paneDraggingEnabled) {
        return NO;
    }
    __block BOOL shouldReceiveTouch = YES;
    // Enumerate the view's superviews, checking for a touch-forwarding class
    [touch.view superviewHierarchyAction:^(UIView *view) {
        // Only enumerate while still receiving the touch
        if (shouldReceiveTouch) {
            // If the touch was in a touch forwarding view, don't handle the gesture
            [self.touchForwardingClasses enumerateObjectsUsingBlock:^(Class touchForwardingClass, BOOL *stop) {
                if ([view isKindOfClass:touchForwardingClass]) {
                    shouldReceiveTouch = NO;
                    *stop = YES;
                }
            }];
        }
    }];
    return shouldReceiveTouch;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"frame"] && (object == self.paneView)) {
        CGRect newFrame = CGRectNull;
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            [self updateAppearance];
        }
    }
}

@end
