//
//  DJMakeupPosition.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJMakeupPosition.h"

static NSMutableDictionary *_makeupPosition;
static NSMutableDictionary *_shadowupPosition;

@implementation DJMakeupPosition

+ (NSMutableDictionary *)makeupPosistion {
    if (_makeupPosition == nil) {
        _makeupPosition = [[NSMutableDictionary alloc]init];
        [DJMakeupPosition setMakeupPositionProfile];
    }
    return  _makeupPosition;
}

+ (NSMutableDictionary *)getShadowupPosition {
    if (_shadowupPosition == nil) {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"ShadowupProfile" ofType:@"json"];
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            _shadowupPosition = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        }
    }
    return  _shadowupPosition;
}

+ (void)setMakeupPositionProfile {
    for (NSInteger fileIndex = 1; fileIndex <= 12; fileIndex++) {
        NSMutableDictionary *makeupPositionFile = [[NSMutableDictionary alloc]init];
        NSString *fileName = [NSString stringWithFormat:@"canthuspin_%ld",(long)fileIndex];
        NSString *path  = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
        NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        
        NSInteger lineNumber = 0;
        NSInteger cnt = 0;
        for (NSString *line in [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
            cnt ++;
            if (cnt > 64) {// Prevent reading an empty line.
                break;
            }
            NSMutableArray *pos = [NSMutableArray array];
            // Because the index of eye start from 200, here we add 200.
            NSArray *numberArray = [line componentsSeparatedByString:@" "];
            if ([numberArray count] == 3) {
                lineNumber = [numberArray[0] integerValue] + 200;
                [pos addObject:[NSNumber numberWithInteger:[numberArray[1] integerValue]]];
                [pos addObject:[NSNumber numberWithInteger:[numberArray[2] integerValue]]];
            }
            
            [makeupPositionFile setValue:pos
                                  forKey:[NSString stringWithFormat:@"%ld", (long)lineNumber]];
        }
        [_makeupPosition setValue:makeupPositionFile forKey:[NSString stringWithFormat:@"makeup%ld",(long)fileIndex]];
    }
}




@end
