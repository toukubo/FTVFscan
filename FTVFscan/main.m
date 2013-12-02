//
//  main.m
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FTVAppDelegate.h"

int main(int argc, char * argv[])
{
#ifdef DEBUG
    int retVal = -1;
    @autoreleasepool {
        @try {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([FTVAppDelegate class]));
        }
        @catch (NSException* exception) {
            NSLog(@"Uncaught exception: %@", exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        }
    }
    return retVal;
#else
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([FTVAppDelegate class]));
    }
#endif
}
