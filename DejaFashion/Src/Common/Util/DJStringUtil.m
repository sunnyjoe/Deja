//
//  DJStringUtil.m
//  DejaFashion
//
//  Created by Kevin Lin on 19/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJStringUtil.h"

@implementation DJStringUtil

+ (NSString *)stringFromPrice:(float)price currencyCode:(NSString *)currencyCode
{
    if (price > 0) {
        return [NSString stringWithFormat:@"%@%.2f", currencyCode , price];
    }
    return @"";
}


+ (NSString *)stringFromTersePrice:(float)price currencyCode:(NSString *)currencyCode
{
    if (price > 0) {
        return [NSString stringWithFormat:@"%@%.1f", currencyCode, price];
    }
    return @"";
}


+ (NSString *)stringFromDejaPrice:(float)price currencyCode:(NSString *)currencyCode
{
    if (price > 0) {
        return [NSString stringWithFormat:@"%@ %@%.2f", @"DEJA", currencyCode, price];
    }
    return @"";
}

+ (NSString *)stringFromTerseDejaPrice:(float)price currencyCode:(NSString *)currencyCode
{
    if (price > 0) {
        return [NSString stringWithFormat:@"%@ %@%.0f", @"DEJA", currencyCode, price];
    }
    return @"";
}

+ (NSString *)localize: (NSString *)str comment:(NSString *)comment
{
    return MOLocalizedString(str, @"");
}

@end
