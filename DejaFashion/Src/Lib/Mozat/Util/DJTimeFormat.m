//
//  DJTimeFormat.m
//  DejaFashion
//
//  Created by DanyChen on 8/6/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJTimeFormat.h"

@implementation DJTimeFormat

+ (NSString *)formatWithTimeIntervalSince1970:(UInt64)seconds
{
    if (seconds == 0) {
        return @"";
    }
    
    NSDate *current = [NSDate date];
    SInt64 interval = current.timeIntervalSince1970 - seconds;
    if(interval <= 0){
        return MOLocalizedString(@"Just Now", @"");
    }
    
    SInt64 y = interval / (365 * 24 * 3600);
    if (y > 0) {
        return [NSString stringWithFormat:MOLocalizedString(@"%lld y", @""), y];
    }
    UInt64 w = interval / (7 * 24 * 3600);
    if (w > 0) {
        return [NSString stringWithFormat:MOLocalizedString(@"%lld w", @""), w];
    }
    UInt64 d = interval / (24 * 3600);
    if (d > 0) {
        return [NSString stringWithFormat:MOLocalizedString(@"%lld d", @""), d];
    }
    UInt64 h = interval / (3600);
    if (h > 0) {
        return [NSString stringWithFormat:MOLocalizedString(@"%lld h", @""), h];
    }
    UInt64 m = interval / (60);
    if (m >= 3) {
        return [NSString stringWithFormat:MOLocalizedString(@"%lld m", @""), m];
    }
    return MOLocalizedString(@"Just Now", @"");
}

@end
