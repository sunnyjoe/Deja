//
//  MONetTaskChain.m
//  Mozat
//
//  Created by Kevin Lin on 15/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import "MONetTaskChain.h"

@interface MONetTaskChain()<MONetTaskDelegate>

@property (nonatomic, strong) NSArray *allTasks;
@property (nonatomic, assign) int taskIndex;

@end

@implementation MONetTaskChain

- (void)setTasks:(MONetTask *)task, ...
{
    NSMutableArray *tasks = [NSMutableArray array];
    va_list args;
    va_start(args, task);
    MONetTask *nextTask = nil;
    for (nextTask = task; nextTask != nil; nextTask = va_arg(args, MONetTask *)) {
        _lastTask = nextTask;
        [tasks addObject:nextTask];
        [[MONetTaskQueue instance] addTaskDelegate:self uri:nextTask.uri];
    }
    va_end(args);
    self.allTasks = tasks;
}

- (BOOL)onNextRequest:(MONetTask *)task
{
    return YES;
}

- (void)onNextResponse:(MONetTask *)task
{
    
}

- (void)start
{
    if (_started) {
        return;
    }
    _started = YES;
    self.taskIndex = 0;
    [self nextRequest];
}

- (void)cancel
{
    if (!_started) {
        return;
    }
    _started = NO;
    for (MONetTask *task in self.allTasks) {
        [[MONetTaskQueue instance] cancelTask:task];
    }
}

- (void)nextRequest
{
    while (_started) {
        if (self.taskIndex >= self.allTasks.count) {
            _started = NO;
            [self.delegate netTaskChainDidEnd:self];
            return;
        }
        MONetTask *task = [self.allTasks objectAtIndex:self.taskIndex];
        self.taskIndex ++;
        if ([self onNextRequest:task]) {
            [[MONetTaskQueue instance] addTask:task];
            return;
        }
    }
}

- (void)netTaskDidEnd:(MONetTask *)task
{
    if (![self.allTasks containsObject:task]) {
        return;
    }
    [self onNextResponse:task];
    [self nextRequest];
}

- (void)netTaskDidFail:(MONetTask *)task
{
    if (![self.allTasks containsObject:task]) {
        return;
    }
    [self.delegate netTaskChainDidFail:self];
}

@end
