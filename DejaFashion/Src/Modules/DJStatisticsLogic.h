//
//  DJStatisticsLogic.h
//  Mozat
//
//  Created by sunlin on 3/6/13
//  Copyright (c) 2013 MOZAT Pte Ltd_ All rights reserved
//

#import <Foundation/Foundation.h>
#import "NSDate+MOAdditions.h"


#if APPSTORE

#define UMENG 1
#define ADJUST 1
#define APPS_FLYER 1

#elif PRODUCT

#define UMENG 0
#define ADJUST 0
#define APPS_FLYER 0

#elif TEST

#define UMENG 1
#define ADJUST 0
#define APPS_FLYER 0

#endif


#define kStatisticsID_http_cost     @"http_time_cost"
#define kStatisticsID_http_error     @"http_time_error"


@interface DJStatisticsLogic : NSObject

+ (DJStatisticsLogic *)instance;

- (void) addTraceLog:(NSString *)eventID;
- (void) addTraceLog:(NSString *)eventID withParameter:(NSDictionary *)parameter;
- (void) addTraceLog:(NSString *)eventID counter:(NSInteger)counter;

- (void) handleAfterAppBecomeActive;
- (void) reportTimeCost:(NSString *)eventId withParameter:(NSDictionary *)parameter timeInMills:(int) timeInMills;

- (void) setup;
- (void) beginLogPageView:(NSString *)pageName;
- (void) endLogPageView:(NSString *)pageName;
@end
