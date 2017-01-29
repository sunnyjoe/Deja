//
//  PerforMadNSLog.h
//  PerforMadTrackingCodeSample
//
//  Created by 万 永庆 on 12/11/14.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PerforMadNSLogLevelNone  = 0,
    PerforMadNSLogLevelCrit  = 10,
    PerforMadNSLogLevelError = 20,
    PerforMadNSLogLevelWarn  = 30,
    PerforMadNSLogLevelInfo  = 40,
    PerforMadNSLogLevelDebug = 50
} PerforMadNSLogLevel;

void PerforMadNSLogSetLogLevel(PerforMadNSLogLevel level);

// The actual function name has an underscore prefix, just so we can
// hijack PerforMadNSLog* with other functions for testing, by defining
// preprocessor macros
void _PerforMadNSLogCrit(NSString *format, ...);
void _PerforMadNSLogError(NSString *format, ...);
void _PerforMadNSLogWarn(NSString *format, ...);
void _PerforMadNSLogInfo(NSString *format, ...);
void _PerforMadNSLogDebug(NSString *format, ...);

#ifndef PerforMadNSLogCrit
#define PerforMadNSLogCrit(...) _PerforMadNSLogCrit(__VA_ARGS__)
#endif

#ifndef PerforMadNSLogError
#define PerforMadNSLogError(...) _PerforMadNSLogError(__VA_ARGS__)
#endif

#ifndef PerforMadNSLogWarn
#define PerforMadNSLogWarn(...) _PerforMadNSLogWarn(__VA_ARGS__)
#endif

#ifndef PerforMadNSLogInfo
#define PerforMadNSLogInfo(...) _PerforMadNSLogInfo(__VA_ARGS__)
#endif

#ifndef PerforMadNSLogDebug
#define PerforMadNSLogDebug(...) _PerforMadNSLogDebug(__VA_ARGS__)
#endif
