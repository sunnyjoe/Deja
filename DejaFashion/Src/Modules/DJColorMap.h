//
//  DJColorMap.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

/** Use to store the color mapping data for different color index.
 * For both skin and hair color index.
 * The skin and hair color is changed based on the color_chart file.
 * Since the file size is very small, we cache it in NSMutableDictionary * colorMap.
 * Just using [DJColorMap colorMap] to get the color mapping data.
 */
#import <Foundation/Foundation.h>

@interface DJColorMap : NSObject

+ (NSMutableDictionary *)colorMap;
+ (NSMutableDictionary *)makeupColorMap;
+ (UIColor *)colorValue:(NSString *)hairOrSkin colorIndex:(NSString *)colorId colorNamed:(NSString *)colorName;

@end
