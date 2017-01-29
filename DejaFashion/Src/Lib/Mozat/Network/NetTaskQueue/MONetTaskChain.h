//
//  MONetTaskChain.h
//  Mozat
//
//  Created by Kevin Lin on 15/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MONetTaskQueue.h"

@class MONetTaskChain;

@protocol MONetTaskChainDelegate <NSObject>

- (void)netTaskChainDidEnd:(MONetTaskChain *)netTaskChain;
- (void)netTaskChainDidFail:(MONetTaskChain *)netTaskChain;

@end

@interface MONetTaskChain : NSObject

@property (nonatomic, weak) id<MONetTaskChainDelegate> delegate;
@property (nonatomic, readonly, assign) BOOL started;
@property (nonatomic, readonly, strong) MONetTask *lastTask;

- (void)setTasks:(MONetTask *)task, ...;
// Return NO indicates this task should not be sent.
- (BOOL)onNextRequest:(MONetTask *)task;
- (void)onNextResponse:(MONetTask *)task;
- (void)start;
- (void)cancel;

@end
