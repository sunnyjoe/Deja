//
//  MONetTaskQueue.h
//  Mozat
//
//  Created by Kevin Lin on 15/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MONetTask.h"

#define kMONetTaskQueueErrorParseFailure @"kMONetTaskQueueErrorParseFailure"

@class MONetTaskQueue;

@protocol MONetTaskDelegate <NSObject>

- (void)netTaskDidEnd:(MONetTask *)task;
- (void)netTaskDidFail:(MONetTask *)task;

@end

@protocol MONetTaskQueueDelegate <NSObject>

// @return unique taskId of this task
- (void)netTaskQueue:(MONetTaskQueue *)netTaskQueue task:(MONetTask *)task taskId:(int)taskId;

@end

@interface MONetTaskQueue : NSObject

@property (nonatomic, weak) id<MONetTaskQueueDelegate> delegate;

+ (instancetype)instance;
- (void)addTask:(MONetTask *)task;
- (void)cancelTask:(MONetTask *)task;
- (void)didResponse:(NSObject *)response taskId:(int)taskId;
- (void)didFailWithError:(NSError *)error taskId:(int)taskId;
- (void)addTaskDelegate:(id<MONetTaskDelegate>)delegate uri:(NSString *)uri;

@end
