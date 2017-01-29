//
//  DJStringUtil.h
//  DejaFashion
//
//  Created by Kevin Lin on 19/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MOLocalizedString(key, comment) NSLocalizedString(key, comment)

@interface DJStringUtil : NSObject

+ (NSString *)stringFromPrice:(float)price currencyCode:(NSString *)currencyCode;
+ (NSString *)stringFromTersePrice:(float)price currencyCode:(NSString *)currencyCode;
+ (NSString *)stringFromDejaPrice:(float)price currencyCode:(NSString *)currencyCode;
+ (NSString *)stringFromTerseDejaPrice:(float)price currencyCode:(NSString *)currencyCode;

+ (NSString *)localize: (NSString *)str comment:(NSString *)comment;
@end
