//
//  FTVUser.m
//  FTVFscan
//
//  Created by Alsor Zhou on 13-10-29.
//  Copyright (c) 2013年 T2. All rights reserved.
//

#import "FTVUser.h"

@implementation FTVUser

+ (NSString*)getId
{
    
//    NSString *fakeUDID=[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor1]];
    
//    DLog(@"%@",fakeUDID);
    
//    return fakeUDID;
    return [ self getUUID ];
    
}

+ (NSString *)getUUID
{
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"uniqueID"];
    if (!UUID) {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
//        UUID = [(__bridge NSString*)string stringByReplacingOccurrencesOfString:@"-"withString:@""];
        [[NSUserDefaults standardUserDefaults] setValue:UUID forKey:@"uniqueID"];
    }
    return UUID;
}





@end
