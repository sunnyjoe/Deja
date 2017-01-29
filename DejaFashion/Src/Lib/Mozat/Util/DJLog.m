//
//  DJLog.m
//  Mozat
//
//  Created by DuanDavid on 9/2/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#if (defined APPSTORE)
#define LOG_LEVEL_DEF DDLogLevelError
#else
#define LOG_LEVEL_DEF DDLogLevelAll
#endif

#import "DJLog.h"
#import "DDLog.h"
#import "DDLogMacros.h"

static NSDictionary *allowedModules;

const static NSString *UI_THREAD_NAME = @"UI";
const static NSString *UI_BACKGROUND_NAME = @"BG";

@implementation DJLog

+ (BOOL)allowToPrintLog:(NSString *)module
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        allowedModules = @{ DJ_SYSTEM: @"",
                            DJ_NETWORK: @"",
                            DJ_DATABASE: @"",
                            DJ_UI: @"" };
    });
    return [allowedModules objectForKey:module] != nil;
}

+ (void)info:(NSString *)module content:(NSString *)content, ...
{
    if ([self allowToPrintLog:module]) {
        va_list args;
        va_start(args, content);
        content = [[NSString alloc] initWithFormat:content arguments:args];
        va_end(args);
        DDLogInfo(@"%@=>%@", [NSThread isMainThread] ? UI_THREAD_NAME : UI_BACKGROUND_NAME, content);
    }
}

+ (void)error:(NSString *)module content:(NSString *)content, ...
{
    if ([self allowToPrintLog:module]) {
        va_list args;
        va_start(args, content);
        content = [[NSString alloc] initWithFormat:content arguments:args];
        va_end(args);
        DDLogError(@"%@=>%@", [NSThread isMainThread] ? UI_THREAD_NAME : UI_BACKGROUND_NAME, content);
    }
}

+ (void)warn:(NSString *)module content:(NSString *)content, ...
{
    if ([self allowToPrintLog:module]) {
        va_list args;
        va_start(args, content);
        content = [[NSString alloc] initWithFormat:content arguments:args];
        va_end(args);
        DDLogWarn(@"%@=>%@", [NSThread isMainThread] ? UI_THREAD_NAME : UI_BACKGROUND_NAME, content);
    }
}

+ (void)verbose:(NSString *)module content:(NSString *)content, ...
{
    if ([self allowToPrintLog:module]) {
        va_list args;
        va_start(args, content);
        content = [[NSString alloc] initWithFormat:content arguments:args];
        va_end(args);
        DDLogVerbose(@"%@=>%@", [NSThread isMainThread] ? UI_THREAD_NAME : UI_BACKGROUND_NAME, content);
    }
}

@end
