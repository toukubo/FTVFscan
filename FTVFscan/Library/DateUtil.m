//
//  DateUtil.m
//  NC
//
//  Created by synnex on 10-12-10.
//  Copyright 2010 synnex. All rights reserved.
//

#import "DateUtil.h"



@implementation DateUtil

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

+ (NSString *) formateDate: (NSDate *) date
				withFormat: (NSString *) format
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: format];
	
	NSString *returnString = [dateFormatter stringFromDate: date];
    
	SAFE_ARC_RELEASE(dateFormatter);
	
	return returnString;
}


+ (NSString *) dateAsString: (NSDate *) date 
				  dateStyle: (NSDateFormatterStyle) dateStyle 
				  timeStyle: (NSDateFormatterStyle) timeStyle
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	NSString* dateString = nil;
	[dateFormatter setDateStyle: dateStyle];
	[dateFormatter setTimeStyle: timeStyle];
	dateString = [dateFormatter stringFromDate: date];
	SAFE_ARC_RELEASE(dateFormatter);
	
	return dateString;
}

+ (NSDate *) parseDate: (NSString *) dateString 
				format: (NSString *) format
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: format];
	NSDate* date = [dateFormatter dateFromString: dateString];
	SAFE_ARC_RELEASE(dateFormatter);
	
	return date;
}

+ (NSDate *) parseDate: (NSString *) dateString
				formatStyle: (NSDateFormatterStyle)style
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:style];
	NSDate* date = [dateFormatter dateFromString: dateString];
	SAFE_ARC_RELEASE(dateFormatter);
	
	return date;
}


+ (NSString *) localizedDateString: (NSDate *) date
{
	// NSLocale* currentLocale = [[NSLocale alloc] initWithLocaleIdentifier: [SysUtil currentDeviceLanguage]];
	NSLocale* currentLocale = [NSLocale currentLocale];
	return [DateUtil localizedDateString:date withLocale:currentLocale];
}

+ (NSString *) localizedDateString: (NSDate *) date withLocale:(NSLocale *)locale
{

	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	
	[dateFormatter setLocale: locale];
	NSString* localizedString = [dateFormatter stringFromDate: date];
	
	SAFE_ARC_RELEASE(dateFormatter);
	
	return localizedString;
}

+ (NSString *) convertTimestampToRelativeTimeInStringFormat:(NSDate *)timestamp
{
	NSString *_timestamp;

    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, [timestamp timeIntervalSince1970]);

    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? LOCALIZE(@"relative_time_seconds_ago") : LOCALIZE(@"relative_time_seconds_ago")];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? LOCALIZE(@"relative_time_minutes_ago") : LOCALIZE(@"relative_time_minutes_ago")];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? LOCALIZE(@"relative_time_hours_ago") : LOCALIZE(@"relative_time_hours_ago")];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? LOCALIZE(@"relative_time_days_ago") : LOCALIZE(@"relative_time_days_ago")];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? LOCALIZE(@"relative_time_months_ago") : LOCALIZE(@"relative_time_months_ago") ];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp timeIntervalSince1970]];        
        _timestamp = [dateFormatter stringFromDate:date];
    }
    return _timestamp;
}
@end