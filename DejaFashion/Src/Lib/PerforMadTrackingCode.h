//
//  PerforMadTrackingCode.h
//  PerforMadTrackingCodeSample
//
//  Created by 万 永庆 on 12/9/14.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SM_CONVERSION_ID    @"SM_CONVERSION_ID"

#define POLICY_CUSTOM   (-1)
#define POLICY_REAL     (0)


@interface PerforMadTrackingCode : NSObject

+ (void)setCoversionId:(NSString *)conversionId;

+ (void)setMarketChannel:(NSString *)marketId;

+ (void)start:(id)currentContainer;

+ (void)stop:(id)currentContainer;

+ (void)events:(NSString *)category action:(NSString *)action;
+ (void)events:(NSString *)category action:(NSString *)action label:(NSString *)label;


+ (void)dispatchPolicy:(NSInteger)policy;
+ (void)dispatchPolicy:(NSInteger)policy isOnlyWifi:(BOOL)isOnlyWifi;

+ (void)dispatch;


+ (void)getCustomURLSchemes:(NSString *)url;
+ (void)setDebugMode:(BOOL)debugMode;

@end
