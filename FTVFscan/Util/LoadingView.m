//  Copyright 2010 dotswitch inc. All rights reserved.

#import "LoadingView.h"


@implementation LoadingView
@synthesize activityIndicator;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor blackColor];
		self.alpha = 0.0;

		self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		activityIndicator.center = self.center;
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];
	}
	return self;
}

- (void)show {
	[UIView beginAnimations:@"ActivityIndicator" context:nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration:0.6];
	self.alpha = 0.9;
	[UIView commitAnimations];
}

- (void)hide {
	[UIView beginAnimations:@"ActivityIndicator" context:nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration:0.6];
	self.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)dealloc {
	self.activityIndicator = nil;
}

@end
