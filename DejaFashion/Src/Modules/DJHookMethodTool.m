//
//  DJHookMethodTool.m
//  DejaFashion
//
//  Created by DanyChen on 13/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "DJHookMethodTool.h"
#import "DejaFashion-Swift.h"
@import Aspects;

@interface HookDemo : NSObject

@end

@implementation HookDemo

-(void)buttonPressed: (UIButton *)button withTag: (NSInteger)tag {
    NSLog(@"buttonPressed:withTag:");
}

-(void)buttonPressed: (UIButton *)button {
    NSLog(@"buttonPressed:");
}

@end

@implementation DJHookMethodTool

static NSMutableArray* hookTokens;

+(void)load {
    hookTokens = [NSMutableArray new];
}
/*
 Config.json
 [{"class_name" : "", "selector_name" : "", "statistics_key" : ""}]
 
 */

+ (void)hookStatistics {
    NSArray *array = [[ConfigDataContainer sharedInstance] getStatisticsSelectors];
    
    if (!array.count) {
        return;
    }
    
    if (hookTokens.count) {
        for (id<AspectToken> token in hookTokens) {
            [token remove];
        }
        [hookTokens removeAllObjects];
    }
    
    for (NSDictionary* dic in array) {
        NSString* className = dic[@"class_name"];
        NSString* selectorName = dic[@"selector_name"];
        NSString* statisticsKey = dic[@"statistics_key"];
        if (className.length && selectorName.length && statisticsKey.length) {
            Class targetClass = NSClassFromString(className);
            SEL targetSelector = NSSelectorFromString(selectorName);
            NSError *error;
            id<AspectToken> token = [targetClass aspect_hookSelector:targetSelector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
                NSLog(@"hook Selector : %@", selectorName);
                [[DJStatisticsLogic instance] addTraceLog:statisticsKey];
            } error:&error];
            if (error) {
            }
            if (token) {
                [hookTokens addObject:token];
            }

        }
    }    
}

@end
