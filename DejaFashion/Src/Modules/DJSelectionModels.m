//
//  DJSelectionModels.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 11/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJSelectionModels.h"
#import "DejaFashion-Swift.h"

static NSMutableDictionary *_hairModels = nil; // Store the information of parts.
static NSMutableDictionary *_makeupOrder = nil; // Store the information of parts.
static NSMutableArray *_templatesArry = nil;

@implementation DJSelectionModels
+(NSMutableDictionary *)getHairModels {
    if (_hairModels == nil) {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"HairSelection" ofType:@"json"];
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        _hairModels = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    }
    return  _hairModels;
}

+(int)getHairModelsCount {
    NSMutableDictionary *hairStyle = [DJSelectionModels getHairModels];
    NSMutableArray *hairType = [hairStyle objectForKey:@"type"];
    int begin = 0;
    for (int j = 0; j < [hairType count]; j ++) {
        NSMutableArray *hairModelsLengthTpye = [hairStyle objectForKey:[hairType objectAtIndex:j]];
        begin = begin + (int)[hairModelsLengthTpye count];
    }
    return  begin;
}
+(NSMutableDictionary *)getMakeupOrder {
    if (_makeupOrder == nil) {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"MakeupSelection" ofType:@"json"];
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        _makeupOrder = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    }
    return  _makeupOrder;
}

+(NSMutableArray *)getTemplatesInfo {
    if (_templatesArry == nil) {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"AddByPhotoTemplate" ofType:@"json"];
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *tmp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *tmpAry = [tmp objectForKey:@"data"];
        _templatesArry = [NSMutableArray new];
        for (NSDictionary *dicT in tmpAry) {
            TemplateInfo *oneInfo = [TemplateInfo new];
            oneInfo.id = dicT[@"id"];
            oneInfo.info = dicT[@"clotheInfo"];
            NSString *name = [NSString stringWithFormat:@"%@Template.png", oneInfo.id];
            oneInfo.template = [UIImage imageNamed:name];
            name = [NSString stringWithFormat:@"%@mask.png", oneInfo.id];
            oneInfo.mask = [UIImage imageNamed:name];
            name = [NSString stringWithFormat:@"%@TemplateIcon.png", oneInfo.id];
            oneInfo.icon = [UIImage imageNamed:name];
            
            [_templatesArry addObject:oneInfo];
        }
    }
    return  _templatesArry;
}

@end
