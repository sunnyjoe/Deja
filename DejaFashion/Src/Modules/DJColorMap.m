//
//  DJColorMap.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJColorMap.h"
#define RGB_N(v) (v) / 255.0f

static NSMutableDictionary * _normalColorChart = nil; // Store the information of parts.
static NSMutableDictionary * _makeupColorChart = nil; // Store the information of parts.

@implementation DJColorMap


+ (NSMutableDictionary *)colorMap {
    if (_normalColorChart == nil) {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"DejaColor" ofType:@"json"];
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            _normalColorChart = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        }
    }
    return  _normalColorChart;
}

+ (NSMutableDictionary *)makeupColorMap {
    if (_makeupColorChart == nil) {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"MakeupColorChanges" ofType:@"json"];
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData){
            _makeupColorChart = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        }
    }
    return  _makeupColorChart;
}

+ (UIColor *)colorValue:(NSString *)hairOrSkin colorIndex:(NSString *)colorId colorNamed:(NSString *)colorName{
    NSMutableArray *changeColorIndex  = [[DJColorMap colorMap] objectForKey:hairOrSkin];
    NSMutableDictionary *colorindex;
    for (int i = 0; i < [changeColorIndex count]; i++) {
        colorindex = [changeColorIndex objectAtIndex:i];
        NSString *tmp = [colorindex objectForKey:@"id"];
        NSRange range = [[NSString stringWithFormat:@"%@",colorId] rangeOfString:@"Color"];
        if (range.location == NSNotFound ) {
            tmp = [tmp substringWithRange:NSMakeRange(9, [tmp length] - 9)];
        }
        if ([tmp isEqualToString:colorId]) {
            break;
        }
    }
    
    uint result = 0;
    if (colorindex) {
        NSString *colorFill = [colorindex objectForKey:colorName];
        NSScanner *scanner = [NSScanner scannerWithString:colorFill];
        [scanner setScanLocation:0]; // bypass '#' character
        [scanner scanHexInt:&result];
    }
    
    int  rebB = result % 256;
    result = result / 256;
    int  rebG = result % 256;
    result = result / 256;
    int  rebR = result;
    
    
    UIColor *outColor = [UIColor colorWithRed:RGB_N(rebR)
                                        green:RGB_N(rebG)
                                         blue:RGB_N(rebB)
                                        alpha:1];
    
    
    return  outColor;
}


@end
