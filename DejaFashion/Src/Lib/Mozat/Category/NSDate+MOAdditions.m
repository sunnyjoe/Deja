//
//  NSDate+MOAdditions.m
//  DejaFashion
//
//  Created by Sun lin on 25/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "NSDate+MOAdditions.h"

@implementation NSDate (MOAdditions)

+ (UInt64)currentTimeSecond
{
    UInt64 curTime = [[NSDate date] timeIntervalSince1970];
    return curTime;
}

+ (UInt64)currentTimeMillis
{
    UInt64 curTime = [[NSDate date] timeIntervalSince1970] * 1000;
    return curTime;
}

- (NSString*)formatFullTime
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      formatter = [[NSDateFormatter alloc] init];
                      [formatter setDateStyle:NSDateFormatterMediumStyle];
                      //                          formatter.locale = TTCurrentLocale();
                      formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                  });
    return [formatter stringFromDate:self];
}

-(BOOL)pastMoreThanOneNaturalDay
{
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    int tsts = (int)([self timeIntervalSince1970] + [zone secondsFromGMT]) / 86400;
    int tsToday = (int)([[NSDate date] timeIntervalSince1970] + [zone secondsFromGMT]) / 86400;
    
    //	if([dateComponentsNow isEqual:dateComponentsTimestamp]) //today
    if (tsts < tsToday)
    {
        return YES;
    }
    return NO;
}
- (NSString*)formatShortTime {
    
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    int tsts = (int)([self timeIntervalSince1970] + [zone secondsFromGMT]) / 86400;
    int tsToday = (int)([[NSDate date] timeIntervalSince1970] + [zone secondsFromGMT]) / 86400;
    
    //	if([dateComponentsNow isEqual:dateComponentsTimestamp]) //today
    if (tsts == tsToday)
    {
        return [self formatTime];
    }
    //	else if ([dateComponentsNow day] - [dateComponentsTimestamp day] <= 1 )//yesterday
    else if (tsts == tsToday - 1)
    {
        return MOLocalizedString(@"Yesterday", @"");
    }
    //	else if ([dateComponentsNow day] - [dateComponentsTimestamp day] <=7) // Within 7 Days
    else if (tsts >= tsToday - 7)
    {
        static NSDateFormatter* formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          formatter = [[NSDateFormatter alloc] init];
                          formatter.dateFormat = @"EEEE"; //LocalizedString(@"EEEE", @"Date format: Monday (Don't translate if in doubt)");
                          //                          formatter.locale = TTCurrentLocale();
                          formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                      });
        return [formatter stringFromDate:self];
    }
    else {
        static NSDateFormatter* formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          formatter = [[NSDateFormatter alloc] init];
                          [formatter setDateStyle:NSDateFormatterMediumStyle];
                          //                          formatter.locale = TTCurrentLocale();
                          formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                      });
        return [formatter stringFromDate:self];
    }
}


- (NSString*)formatTime {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      formatter = [[NSDateFormatter alloc] init];
                      formatter.dateFormat = @"h:mm a"; //LocalizedString(@"h:mm a", @"Date format: 1:05 pm (Don't translate if in doubt)");
                      formatter.timeStyle = NSDateFormatterShortStyle;
                      //[formatter setTimeStyle:NSDateFormatterShortStyle];
//                      formatter.locale = TTCurrentLocale();
                      formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                  });
    return [formatter stringFromDate:self];
}



NSLocale* TTCurrentLocale() {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
    if (languages.count > 0) {
        NSString* currentLanguage = [languages objectAtIndex:0];
        return [[NSLocale alloc] initWithLocaleIdentifier:currentLanguage];
    } else {
        return [NSLocale currentLocale];
    }
}

@end
