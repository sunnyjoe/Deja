//
//  MONetTaskQueue.m
//  Mozat
//
//  Created by Kevin Lin on 15/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import "MONetTaskQueue.h"

@interface MONetTaskDelegateWeakWrapper : NSObject

@property (nonatomic, weak) id<MONetTaskDelegate> delegate;

@end

@implementation MONetTaskDelegateWeakWrapper

@end

static MONetTaskQueue *sharedInstance;

@interface MONetTaskQueue()

@property (atomic, strong) NSMutableDictionary *tasks; // <NSNumber, MONetTask>
@property (atomic, strong) NSMutableDictionary *taskDelegates; // <NSString, NSArray<MONetTaskDelegate>>
@property (atomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) int currentTaskId;

@end

@implementation MONetTaskQueue

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init
{
    NSAssert(!sharedInstance, @"This should be a singleton class.");
    
    if (self = [super init]) {
        self.tasks = [NSMutableDictionary new];
        self.taskDelegates = [NSMutableDictionary new];
        self.queue = [NSOperationQueue new];
        self.queue.name = @"MONetTaskQueue";
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)addTask:(MONetTask *)task
{
    NSAssert(self.delegate, @"MONetTaskQueueDelegate is not set.");
    
    __weak MONetTaskQueue *weakSelf = self;
    [self.queue addOperationWithBlock:^ {
        int taskId;
        @synchronized(self) {
            weakSelf.currentTaskId ++;
            taskId = weakSelf.currentTaskId;
        }
        [self.delegate netTaskQueue:self task:task taskId:taskId];
        @synchronized(weakSelf.tasks) {
            [weakSelf.tasks setObject:task forKey:@(taskId)];
        }
    }];
}

- (void)cancelTask:(MONetTask *)task
{
    __weak MONetTaskQueue *weakSelf = self;
    [self.queue addOperationWithBlock:^ {
        
        @synchronized(weakSelf.tasks) {
            NSNumber *seqToBeRemoved = nil;
            for (NSNumber *seq in weakSelf.tasks.allKeys) {
                if ([weakSelf.tasks objectForKey:seq] == task) {
                    seqToBeRemoved = seq;
                    break;
                }
            }
            if (seqToBeRemoved) {
                [weakSelf.tasks removeObjectForKey:seqToBeRemoved];
            }
        }
    }];
}

- (void)didResponse:(NSObject *)response taskId:(int)taskId
{
    __weak MONetTaskQueue *weakSelf = self;
    [self.queue addOperationWithBlock:^ {
        
        MONetTask *task = nil;
        @synchronized(weakSelf.tasks) {
            task = [weakSelf.tasks objectForKey:@(taskId)];
            if (!task) {
                return;
            }
            [weakSelf.tasks removeObjectForKey:@(taskId)];
        }
        
        [[DJStatisticsLogic instance] reportTimeCost:kStatisticsID_http_cost withParameter:@{ @"api" : task.uri} timeInMills:(int)([NSDate currentTimeMillis] - task.requestTimeInMills)];
        
        @try {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [task didResponse:response];
                [weakSelf netTaskDidEnd:task];
            });
        }
        @catch (NSException *exception) {
            [weakSelf log:[NSString stringWithFormat:@"Exception in 'didResponse'[uri:%@] - %@", task.uri, [exception description]]];
            NSError *error = [NSError errorWithDomain:kMONetTaskQueueErrorParseFailure
                                                 code:-1
                                             userInfo:@{ @"msg": @"Parse failure" }];
            task.error = error;
            [weakSelf netTaskDidFail:task];
            return;
        }
    }];
}

- (void)didFailWithError:(NSError *)error taskId:(int)taskId
{
    __weak MONetTaskQueue *weakSelf = self;
    [self.queue addOperationWithBlock:^ {
        
        MONetTask *task = nil;
        @synchronized(weakSelf.tasks) {
            task = [weakSelf.tasks objectForKey:@(taskId)];
            if (!task) {
                return;
            }
            [weakSelf.tasks removeObjectForKey:@(taskId)];
        }
        
        task.error = error;
        dispatch_async(dispatch_get_main_queue(), ^ {
            [task didFail:error];
            [weakSelf netTaskDidFail:task];
        });
    }];
}

- (void)netTaskDidEnd:(MONetTask *)task
{
    NSArray *delegates = [self.taskDelegates objectForKey:task.uri];
    for (MONetTaskDelegateWeakWrapper *weakWrapper in delegates) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [weakWrapper.delegate netTaskDidEnd:task];
        });
    }
}

- (void)netTaskDidFail:(MONetTask *)task
{
    NSArray *delegates = [self.taskDelegates objectForKey:task.uri];
    for (MONetTaskDelegateWeakWrapper *weakWrapper in delegates) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [weakWrapper.delegate netTaskDidFail:task];
        });
    }
}

- (void)addTaskDelegate:(id<MONetTaskDelegate>)delegate uri:(NSString *)uri
{
    NSAssert([NSThread isMainThread], @"addTaskDelegate: must be involked in main thread.");
    NSAssert(delegate && uri, @"addTaskDelegate: trying to addTaskDelegate with nil delegate or uri.");
    
    NSMutableArray *delegates = [self.taskDelegates objectForKey:uri];
    if (!delegates) {
        delegates = [NSMutableArray new];
        [self.taskDelegates setObject:delegates forKey:uri];
    }
    
    BOOL delegateExisted = NO;
    NSMutableArray *toBeDeleted = [NSMutableArray new];
    for (MONetTaskDelegateWeakWrapper *weakWrapper in delegates) {
        if (weakWrapper.delegate == delegate) {
            delegateExisted = YES;
        }
        if (!weakWrapper.delegate) {
            [toBeDeleted addObject:weakWrapper];
        }
    }
    
    [delegates removeObjectsInArray:toBeDeleted];
    
    if (!delegateExisted) {
        MONetTaskDelegateWeakWrapper *weakWrapper = [MONetTaskDelegateWeakWrapper new];
        weakWrapper.delegate = delegate;
        
        [delegates addObject:weakWrapper];
    }
}

- (void)log:(NSString *)content
{
    NSLog(@"MONetTaskQueue: %@", content);
}

@end