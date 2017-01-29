//
//  PerforMadNSLog.m
//  PerforMadTrackingCodeSample
//
//  Created by 万 永庆 on 12/11/14.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//

#import "PerforMadNSLog.h"


static PerforMadNSLogLevel g_PerforMadNSLogLevel = PerforMadNSLogLevelInfo;

void PerforMadNSLogSetLogLevel(PerforMadNSLogLevel level) {
    g_PerforMadNSLogLevel = level;
}

void _PerforMadNSLogCrit(NSString *format, ...) {
    if (g_PerforMadNSLogLevel < PerforMadNSLogLevelCrit) return;
    va_list ap;
    va_start(ap, format);
    NSLogv(format, ap);
    va_end(ap);
}

void _PerforMadNSLogError(NSString *format, ...) {
    if (g_PerforMadNSLogLevel < PerforMadNSLogLevelError) return;
    va_list ap;
    va_start(ap, format);
    NSLogv(format, ap);
    va_end(ap);
}

void _PerforMadNSLogWarn(NSString *format, ...) {
    if (g_PerforMadNSLogLevel < PerforMadNSLogLevelWarn) return;
    va_list ap;
    va_start(ap, format);
    NSLogv(format, ap);
    va_end(ap);
}

void _PerforMadNSLogInfo(NSString *format, ...) {
    if (g_PerforMadNSLogLevel < PerforMadNSLogLevelInfo) return;
    va_list ap;
    va_start(ap, format);
    NSLogv(format, ap);
    va_end(ap);
}

void _PerforMadNSLogDebug(NSString *format, ...) {
    if (g_PerforMadNSLogLevel < PerforMadNSLogLevelDebug) return;
    va_list ap;
    va_start(ap, format);
    NSLogv(format, ap);
    va_end(ap);
}
