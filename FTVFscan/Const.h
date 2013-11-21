//
//  Const.h
//  FTVFscan
//
//  Created by Koji TOUKUBO on 10/28/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#ifndef FTVFscan_Const_h
#define FTVFscan_Const_h

#ifdef DEBUG
    #define BASEURL @"http://zxc.cz/fscan-web-staging/"
#elif
    #define BASEURL @"http://zxc.cz/fscan-web/"
#endif

#define IPHONE_HEIGHT 480
#define MAX_PAGE      10

#define TEST_TIME       1                   // change to other integer for performance test purpose

// ---------------------- Notification Names ----------------
#define kNotifyRegisterFinished             @"kNotifyRegisterFinished"


#endif
