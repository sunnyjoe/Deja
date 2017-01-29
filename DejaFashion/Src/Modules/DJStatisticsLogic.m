//
//  DJStatisticsManager.m
//  Mozat
//
//  Created by sunlin on 3/6/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "DJStatisticsLogic.h"
#import "MOUserAgent.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "DJConfigDataContainer.h"
#import "DJUrl.h"
#import "DJUserFeedbackLogic.h"
#import "MobClick.h"
//#import "TalkingData.h"
#import "Adjust.h"
#import <AppsFlyer/AppsFlyer.h>


@implementation DJStatisticsLogic {
    NSMutableArray *userTraceLogsPool;
    NSMutableArray *userBeforeLoginLogsPool;
    BOOL isReportingUserTraceLogs;
    BOOL isReportingBeforLoginLogs;
    NSString* userAgent;
}

static DJStatisticsLogic *_sharedObject = nil;
+ (DJStatisticsLogic *)instance {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[DJStatisticsLogic alloc] init];
    });
    return _sharedObject;
}


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

/**************************************************************
 *
 *
 * eventID words must connect with '_'. eg: enter_fitting_room
 *
 *
 **************************************************************/

-(void)handlEssentialEvent:(NSString *)eventID
{
    NSArray *result = [eventID componentsSeparatedByString:@"_"];
    if (result.count > 2)
    {
//#if TALKING_DATA
//        [TalkingData trackEvent:[NSString stringWithFormat:@"%@_%@", result[0], result[1]]];
//#endif
        
#if UMENG
        [MobClick event:[NSString stringWithFormat:@"%@_%@", result[0], result[1]]];
#endif
    }
    
}

- (void)addTraceLog:(NSString *)eventID
{
    
    [self handlEssentialEvent:eventID];
//#if TALKING_DATA
//    [TalkingData trackEvent:eventID];
//#endif
    
#if UMENG
    [MobClick event:eventID];
#endif
    [[DJUserFeedbackLogic instance] addLogEvent:eventID];
}

- (void) addTraceLog:(NSString *)eventID withParameter:(NSDictionary *)parameter {
    [self handlEssentialEvent:eventID];
//#if TALKING_DATA
//    [TalkingData trackEvent:eventID];
//#endif
    
#if UMENG
    [MobClick event:eventID attributes:parameter];
#endif
    [[DJUserFeedbackLogic instance] addLogEvent:eventID];
}

-(void)addTraceLog:(NSString *)eventID counter:(NSInteger)counter
{
#if UMENG
    [MobClick event:eventID attributes:[NSDictionary new] counter:(int)counter];
#endif
}

- (void) reportTimeCost:(NSString *)eventId withParameter:(NSDictionary *)parameter timeInMills:(int) timeInMills {
#if UMENG
    [MobClick event:(NSString *)eventId attributes:(NSDictionary *)parameter durations:(int)timeInMills];
#endif
}


-(void) setup
{
    
//#if TALKING_DATA
//    [TalkingData sessionStarted:kDJTalkingDataAppId withChannelId:@"APP_STAORE"];
//    [TalkingData setLogEnabled:NO];
//#endif
    
#if UMENG
    [MobClick startWithAppkey:kDJYouMengAppId reportPolicy:SEND_INTERVAL channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick setEncryptEnabled:YES];
    [MobClick setCrashReportEnabled:NO];
#endif
    
#if ADJUST
    NSString *yourAppToken = kDJAdjustAppId;
    NSString *environment = ADJEnvironmentProduction;
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken environment:environment];
    [Adjust appDidLaunch:adjustConfig];
#endif
    
    
#if APPS_FLYER
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = kDJAppsFlyerAppId;
    [AppsFlyerTracker sharedTracker].appleAppID = kDJAppstoreId;
#endif
}

-(void)handleAfterAppBecomeActive
{
#if APPS_FLYER
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
#endif
}

-(void) logAdjustEvent:(NSString *)token
{
#if ADJUST
    ADJEvent *event = [ADJEvent eventWithEventToken:@""];
    [Adjust trackEvent:event];
#endif
}



-(void)beginLogPageView:(NSString *)pageName
{
    
//#if TALKING_DATA
//    [TalkingData trackPageBegin:pageName];
//#endif
    
#if UMENG
    [MobClick beginLogPageView:pageName];
#endif
    
}


-(void)endLogPageView:(NSString *)pageName
{
    
//#if TALKING_DATA
//    [TalkingData trackPageEnd:pageName];
//#endif
    
#if UMENG
    [MobClick endLogPageView:pageName];
#endif
}
@end
