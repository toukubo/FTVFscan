//  Copyright 2010 dotswitch inc. All rights reserved.

#import <UIKit/UIKit.h>


@interface LoadingView : UIView {
	UIActivityIndicatorView *activityIndicator;
}

@property(retain) UIActivityIndicatorView *activityIndicator;

- (void)show;
- (void)hide;
@end
