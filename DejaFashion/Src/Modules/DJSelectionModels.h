//
//  DJSelectionModels.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 11/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DJSelectionModels : NSObject

+(NSMutableDictionary *)getHairModels;
+(int)getHairModelsCount;
+(NSMutableDictionary *)getMakeupOrder;
+(NSMutableArray *)getTemplatesInfo;

@end
