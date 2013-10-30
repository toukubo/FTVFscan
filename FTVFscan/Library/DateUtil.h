//
//  DateUtil.h
//  NC
//
//  Created by synnex on 10-12-10.
//  Copyright 2010 synnex. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateUtil : NSObject

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;

+ (NSString *) formateDate: (NSDate *) date
				withFormat: (NSString *) format;

+ (NSString *) dateAsString: (NSDate *) date 
				  dateStyle: (NSDateFormatterStyle) dateStyle 
				  timeStyle: (NSDateFormatterStyle) timeStyle;

+ (NSDate *) parseDate: (NSString *) dateString 
			 format: (NSString *) format;

+ (NSDate *) parseDate: (NSString *) dateString
           formatStyle: (NSDateFormatterStyle)style;

+ (NSString *) localizedDateString: (NSDate *) date;

+ (NSString *) localizedDateString: (NSDate *) date withLocale:(NSLocale *)locale;

+ (NSString *) convertTimestampToRelativeTimeInStringFormat:(NSDate *)timestamp;

@end


