//
//  DJShareLogNetTask.h
//  DejaFashion
//
//  Created by Kevin Lin on 9/3/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJHTTPNetTask.h"

typedef enum {
    DJShareLogItem = 1,
    DJShareLogCreation = 2,
    DJShareLogEvent = 3,
    DJShareLogWeb = 4
} DJShareLogType;

@interface DJShareLogNetTask : DJHTTPNetTask  

@property (nonatomic, assign) DJShareLogType type;

@end
