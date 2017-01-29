//
//  MONetTask.h
//  Mozat
//
//  Created by Kevin Lin on 15/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MONetTask : NSObject

@property (nonatomic, strong) NSError *error;

- (NSString *)uri;
- (void)didResponse:(NSObject *)response;
- (void)didFail:(NSError *)error;

@property (nonatomic, assign) UInt64 requestTimeInMills;

@end
