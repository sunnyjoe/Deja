//
//  DJNetTaskHandler.h
//  DejaFashion
//
//  Created by Kevin Lin on 11/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MONetTaskQueue.h"

#define kDJNetEventSignatureDidExpire @"kDJNetEventSignatureDidExpire"
#define kDJAPIErrorDomain @"kDJAPIErrorDomain"

@interface DJNetTaskHandler : NSObject<MONetTaskQueueDelegate>

+ (instancetype)instance;

@end
