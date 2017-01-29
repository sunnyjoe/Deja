//
//  PerforMadEventManager.h
//  PerforMadTrackingCodeSample
//
//  Created by 万 永庆 on 12/10/14.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PerforMadUtils.h"
#import "PerforMadReachability.h"

typedef enum {
    EventLA = 0,
    EventEV = 1,
    EVentTE = 2,
}PerforMadEventType;

#define Value_None      [NSNumber numberWithInteger:-1]
#define Session_Null    @"null"
#define Session_Nil     @"nil"

#pragma mark PerforMadEventBase
@interface PerforMadEventBase : NSObject

@property (nonatomic, assign) PerforMadEventType eventType;
@property (nonatomic, copy) NSString *utc;
@property (nonatomic, copy) NSString *sessionId;

- (NSString*)jsonString;
@end


#pragma mark PerforMadEventLA
@interface PerforMadEventLA : PerforMadEventBase
@property (nonatomic, assign) NSInteger aas;

@end



#pragma mark PerforMadEventEV
@interface PerforMadEventEV : PerforMadEventBase
@property (nonatomic, copy) NSString* categary;
@property (nonatomic, copy) NSString* action;
@property (nonatomic, copy) NSString* label;
@property (nonatomic, strong) NSNumber* value;

@end


#pragma mark PerforMadEventTE
@interface PerforMadEventTE : PerforMadEventBase
@property (nonatomic, copy) NSString* controller;
@property (nonatomic, assign) NSInteger duration;

@end


#pragma mark PerforMadEventManager
@protocol PerforMadEventManagerDelegate <NSObject>
- (NSString*)parametersOfUrl;
- (void)changeSessionId:(NSString*)sessionId;
- (PerforMadNetworkStatus)currentNetworkType;
- (BOOL)canSend;
- (void)onSendOK:(NSString*)urlString;
@end;

@interface PerforMadEventManager : NSObject

@property (nonatomic, assign) id<PerforMadEventManagerDelegate> delegate;
@property (nonatomic, assign) NSInteger policy;
@property (nonatomic, assign) BOOL onlyWifi;
@property (nonatomic) NSTimeInterval expiredMax;

- (void)addEvent:(PerforMadEventBase*)event;
- (void)dispatch;
- (NSString*)eventsJsonString;
- (void)send;
- (void)startTimer;
- (void)stopTimer;

@end
