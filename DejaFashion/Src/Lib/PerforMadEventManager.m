//
//  PerforMadEventManager.m
//  PerforMadTrackingCodeSample
//
//  Created by 万 永庆 on 12/10/14.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//

#import "PerforMadEventManager.h"
#import "PerforMadTrackingCode.h"
#import "PerforMadUtils.h"
#import <sqlite3.h>
#import "PerforMadNSLog.h"

#define MAX_LENGTH_EV (6000)

#pragma mark PerforMadEventBase
@implementation PerforMadEventBase

- (NSString*)jsonString {
#if !__has_feature(objc_arc)
    @throw [[[NSException alloc] init] autorelease];
#else
    @throw [[NSException alloc] init];
#endif
}

@end

#pragma mark PerforMadEventLA

@implementation PerforMadEventLA
- (id)init {
    self = [super init];
    if (self)
    {
        self.eventType = EventLA;
    }
    return self;
}
- (NSString*)jsonString {
    NSMutableString *mutableStr = [[NSMutableString alloc] init];
    [mutableStr appendFormat:@"{\"utc\":\"%@\"", self.utc];

    if (self.aas > 0) {
        [mutableStr appendFormat:@",\"aas\":%ld", (long)self.aas];
    }
    if (self.sessionId !=  nil) {
        [mutableStr appendFormat:@",\"sid\":\"%@\"", self.sessionId];
    }
    [mutableStr appendString:@"}"];
    return mutableStr;
}

@end

#pragma mark PerforMadEventEV
@implementation PerforMadEventEV
- (id)init {
    self = [super init];
    if (self) {
        self.eventType = EventEV;
        self.value = Value_None;
    }
    return self;
}

- (NSString*)jsonString {
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    [mutableString appendFormat:@"{\"utc\":\"%@\",\"cat\":\"%@\",\"act\":\"%@\"", self.utc, self.categary, self.action];
    if (self.label != nil) {
        [mutableString appendFormat:@",\"lab\":\"%@\"", self.label];
    }
    if (![self.value isEqualToNumber:Value_None]) {
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        NSString *str;
        if (strcmp([self.value objCType], @encode(float)) == 0)
        {
            [numberFormatter setMinimumFractionDigits:1];
            [numberFormatter setMaximumFractionDigits:16];
            str = [numberFormatter stringFromNumber:self.value];
        }
        else if (strcmp([self.value objCType], @encode(double)) == 0)
        {
            [numberFormatter setMinimumFractionDigits:1];
            [numberFormatter setMaximumFractionDigits:16];
            str = [numberFormatter stringFromNumber:self.value];
        }
        else if (strcmp([self.value objCType], @encode(int)) == 0)
        {
            str = [numberFormatter stringFromNumber:self.value];
        }
        else
        {
            str = [numberFormatter stringFromNumber:self.value];
        }
        [mutableString appendFormat:@",\"val\":%@", str];
    }
    if (self.sessionId != nil) {
        [mutableString appendFormat:@",\"sid\":\"%@\"", self.sessionId];
    }
    [mutableString appendString:@"}"];
#if !__has_feature(objc_arc)
    return [mutableString autorelease];
#else
    return mutableString;
#endif
}

@end

#pragma mark PerforMadEventTE
@implementation PerforMadEventTE
- (id)init {
    self = [super init];
    if (self) {
        self.eventType = EVentTE;
    }
    return self;
}
- (NSString*)jsonString {
    if (self.sessionId != nil) {
        return [NSString stringWithFormat:@"{\"utc\":\"%@\",\"apn\":\"%@\",\"av\":\"%@\",\"awn\":\"%@\",\"dur\":%ld, \"sid\":\"%@\"}",
                self.utc, [PerforMadUtils ApplicationPackageName], [PerforMadUtils ApplicationVersion], self.controller,(long)self.duration, self.sessionId];
    }
    return [NSString stringWithFormat:@"{\"utc\":\"%@\",\"apn\":\"%@\",\"av\":\"%@\",\"awn\":\"%@\",\"dur\":%ld}",
            self.utc, [PerforMadUtils ApplicationPackageName], [PerforMadUtils ApplicationVersion], self.controller,(long)self.duration];
}

@end

#pragma mark PerforMadEventManager
@interface PerforMadEventManager ()<UIWebViewDelegate>
{
    NSMutableArray *_laArray;
    NSMutableArray *_evArray;
    NSMutableArray *_teArray;
    NSInteger _laCount;
    NSInteger _evCount;
    NSInteger _teCount;
    BOOL _firstLaunch;
    UIWebView *_webView;
    BOOL _sending;
    sqlite3 *_database;
    NSTimer *_timer;
    NSInteger _secondsCount;
    NSTimeInterval _expiredMax;
}
@end

@implementation PerforMadEventManager
- (void)dealloc {
    [self stopTimer];
    [self closeDatabase];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}
- (id)init {
    self = [super init];
    if (self) {
        _laArray = [[NSMutableArray alloc] init];
        _evArray = [[NSMutableArray alloc] init];
        _teArray = [[NSMutableArray alloc] init];
        _laCount = 0;
        _evCount = 0;
        _teCount = 0;
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _sending = NO;
        [self openDatabase];
        [self readEventsFromDatabaseToMemory];
        _timer = nil;
        _secondsCount = 0;
        _expiredMax = INT16_MAX;
    }
    return self;
}
- (void)addEvent:(PerforMadEventBase*)event {
    if (![PerforMadUtils trackingEnable]) {
        [self stopTimer];
        return;
    }
    
    [self saveEventToMemory:event];
    
    [self saveEventToDatabase:event];
    
    if (_policy == POLICY_REAL && [self.delegate canSend]) {
        if (!_sending) {
            _sending = YES;
            [NSThread detachNewThreadSelector:@selector(threadSend) toTarget:self withObject:nil];
        }
    }
    else if (_policy > POLICY_REAL) {
        [self startTimer];
    }
}
- (void)saveEventToMemory:(PerforMadEventBase*)event {
    switch (event.eventType) {
        case EventLA:
        {
            [_laArray addObject:[event jsonString]];
        }
            break;
        case EventEV:
        {
            [_evArray addObject:[event jsonString]];
        }
            break;
        case EVentTE:
        {
            [_teArray addObject:[event jsonString]];
        }
            break;
        default:
            break;
    }
}
- (void)dispatch {
    if (self.policy == POLICY_CUSTOM) {
        if (!_sending) {
            _sending = YES;
            [NSThread detachNewThreadSelector:@selector(threadSend) toTarget:self withObject:nil];
        }
    }
}

- (NSString*)eventsJsonString {
    NSInteger lenghtTotal = 0;
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    NSMutableString *las = [[NSMutableString alloc] initWithString:@"\"la\":["];
    NSMutableString *evs = [[NSMutableString alloc] initWithString:@"\"ev\":["];
    NSMutableString *tes = [[NSMutableString alloc] initWithString:@"\"te\":["];
    _laCount = 0;
    _evCount = 0;
    _teCount = 0;
    
    for (NSString *str in _laArray) {
        NSInteger length = [str length];
        if (lenghtTotal + length > MAX_LENGTH_EV) {
            break;
        }
        lenghtTotal += length;
        
        if (_laCount > 0) {
            [las appendString:@","];
            [las appendString:str];
        }
        else {
            [las appendString:str];
        }
        _laCount++;
    }
    
    for (NSString *str in _evArray) {
        NSInteger length = [str length];
        if (lenghtTotal + length > MAX_LENGTH_EV) {
            break;
        }
        lenghtTotal += length;
        
        
        if (_evCount > 0) {
            [evs appendString:@","];
            [evs appendString:str];
        }
        else {
            [evs appendString:str];
        }
        _evCount++;
    }
    
    for (NSString *str in _teArray) {
        NSInteger length = [str length];
        if (lenghtTotal + length > MAX_LENGTH_EV) {
            break;
        }
        lenghtTotal += length;
        
        if (_teCount > 0) {
            [tes appendString:@","];
            [tes appendString:str];
        }
        else {
            [tes appendString:str];
        }
        _teCount++;
    }
    
    [las appendString:@"]"];
    [evs appendString:@"]"];
    [tes appendString:@"]"];
    
    if (_laCount > 0)
    {
        [mutableString appendString:las];
        if (_evCount > 0 || _teCount > 0) {
            [mutableString appendString:@","];
        }
    }
    if (_evCount > 0) {
        [mutableString appendString:evs];
        if (_teCount > 0) {
            [mutableString appendString:@","];
        }
    }
    if (_teCount > 0) {
        [mutableString appendString:tes];
    }
#if !__has_feature(objc_arc)
    return [mutableString autorelease];
#else
    return mutableString;
#endif
}

- (void)threadSend
{
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread:@selector(send) withObject:nil waitUntilDone:NO];
    [pool release];
#else
    @autoreleasepool {
        [self performSelectorOnMainThread:@selector(send) withObject:nil waitUntilDone:NO];
    }
#endif
}

- (void)send {
    if (![PerforMadUtils trackingEnable]) {
        [self stopTimer];
        return;
    }
    
    PerforMadNetworkStatus nt = [self.delegate currentNetworkType];
    if (nt < PerforMadNetwork_Wifi) {
        [self resetStates];
        return;
    }
    if (_onlyWifi) {
        if (nt != PerforMadNetwork_Wifi) {
            [self resetStates];
            return;
        }
    }
    NSString *evString = [self eventsJsonString];
    if (evString && [evString length] > 1) {
        NSMutableString *url = [[NSMutableString alloc] initWithString:SERVER_URL];
        [url appendString:[self.delegate parametersOfUrl]];
        
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:@"{"];
        [mutableString appendString:evString];
        [mutableString appendString:@"}"];
        [PerforMadUtils addKey:@"&et=" assignValue:mutableString for:url];
#if !__has_feature(objc_arc)
        [mutableString release],mutableString = nil;
#endif
        PerforMadNSLogDebug(@"%@", url);
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
#if !__has_feature(objc_arc)
        [url release], url=nil;
#endif
    }
    else {
        [self resetStates];
    }
}

- (void)onSendOK {
    if (_laCount > 0) {
        [self deleteEventType:EventLA withCount:_laCount];
        
        for (NSInteger i=0; i<_laCount; i++) {
            [_laArray removeObjectAtIndex:0];
        }
        _laCount = 0;
    }
    
    if (_evCount > 0) {
        [self deleteEventType:EventEV withCount:_evCount];
        
        for (NSInteger i=0; i<_evCount; i++) {
            [_evArray removeObjectAtIndex:0];
        }
        _evCount = 0;
    }
    
    if (_teCount > 0) {
        [self deleteEventType:EVentTE withCount:_teCount];
        
        for (NSInteger i=0; i<_teCount; i++) {
            [_teArray removeObjectAtIndex:0];
        }
        _teCount = 0;
    }
    
    
    [self resetStates];
    
    if (_policy == POLICY_REAL && [self.delegate canSend]) {
        if (!_sending) {
            _sending = YES;
            [NSThread detachNewThreadSelector:@selector(threadSend) toTarget:self withObject:nil];
        }
    }
    
    [[PerforMadUtils ApplicationVersion] writeToFile:[PerforMadUtils markTrackingCodeAppVersionFile] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSURLRequest *request = [_webView request];
    NSURL *url = [request URL];
    NSString *str = [url absoluteString];
    [self.delegate onSendOK:str];
}
- (void)onSendFail {
    [self resetStates];
}
- (void)resetStates {
    _sending = NO;
}
- (void)handleReturnCode:(NSString*)rc
{/*
  请求成功
  200
  追踪信息服务器已经接收并处理成功。
  请求失败
  400
  追踪信息有误,服务器处理失败。
  验证失败
  401
  追踪信息中校验位验证失败。
  请求关闭
  403
  媒体追踪服务停止,不需要再发送追踪信息。
  */
    [rc writeToFile:[PerforMadUtils markTrackingCodeFileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if ([rc isEqualToString:StatusCode_Success]) {
        [self onSendOK];
    }
    else {
        [self onSendFail];
    }
}

- (void)startTimer {
    if (_timer == nil) {
        _secondsCount = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        
    }
}
- (void)timerFireMethod:(NSTimer *)timer
{
    _secondsCount++;
    if (_secondsCount >= _policy) {
        _secondsCount = 0;
        if (!_sending) {
            _sending = YES;
            [NSThread detachNewThreadSelector:@selector(threadSend) toTarget:self withObject:nil];
        }
    }
}
- (void)stopTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer=nil;
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    PerforMadNSLogDebug(@"shouldStartLoadWithRequest:%@", [[request URL] absoluteString]);
    NSArray* components =[[[request URL] absoluteString] componentsSeparatedByString:@":"];
    //window.location=“TrackingCode:NCTrackingCallback:403:dae1c14030168be6:1800”
    if ([components count] >= 4)
    {
        //        if ([[[components objectAtIndex:0] lowercaseString] isEqualToString:@"PerforMadtrackingcode"])
        {
            NSString *rc = [components objectAtIndex:2];
            if ([rc isEqualToString:StatusCode_Success])
            {
                NSString *sessionId = [components objectAtIndex:3];
                
                if ([components count] >= 5)
                {
                    NSString *expired = [components objectAtIndex:4];
                    NSInteger eInt = [expired integerValue];
                    if (eInt > 0) {
                        _expiredMax =  eInt;
                    }
                }
                
                if (![[sessionId lowercaseString] isEqualToString:Session_Null] &&
                    ![[sessionId lowercaseString] isEqualToString:Session_Nil]
                    )
                {
                    [self.delegate changeSessionId:sessionId];
                    [self handleReturnCode:StatusCode_Success];
                }
                else {//如果当前没有sessionId，服务器又没有下行sessionId，则不作为成功处理
                    NSURLRequest *request = [_webView request];
                    NSURL *url = [request URL];
                    NSString *str = [url absoluteString];
                    NSRange range=[str rangeOfString:@"sid="];
                    if (range.location != NSNotFound) {
                        [self handleReturnCode:StatusCode_Success];
                    }
                    else {
                        [self onSendFail];
                    }
                }
            }
            else {
                [self handleReturnCode:rc];
            }
            
        }
        return NO;
    }
    return YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self onSendFail];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.isLoading) {
        [self resetStates];
    }
}

#pragma mark Database
- (void)openDatabase
{
    NSString *filePath = [PerforMadUtils databaseFileName];
    
    if (sqlite3_open([filePath UTF8String], &_database)
        != SQLITE_OK) {
        sqlite3_close(_database);
        PerforMadNSLogDebug(@"Failed to open _database");
        return;
    }
    
    char *errorMsg=NULL;
    NSString *createSQLla = @"CREATE TABLE IF NOT EXISTS la (row INTEGER PRIMARY KEY AUTOINCREMENT,field_data TEXT);";
    if (sqlite3_exec (_database, [createSQLla  UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        PerforMadNSLogDebug(@"Error creating table la: %s", errorMsg);
        sqlite3_free(errorMsg);
    }
    
    NSString *createSQLev = @"CREATE TABLE IF NOT EXISTS ev (row INTEGER PRIMARY KEY AUTOINCREMENT,field_data TEXT);";
    if (sqlite3_exec (_database, [createSQLev  UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        PerforMadNSLogDebug(@"Error creating table ev: %s", errorMsg);
        sqlite3_free(errorMsg);
    }
    
    
    NSString *createSQLte = @"CREATE TABLE IF NOT EXISTS te (row INTEGER PRIMARY KEY AUTOINCREMENT,field_data TEXT);";
    if (sqlite3_exec (_database, [createSQLte  UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(_database);
        PerforMadNSLogDebug(@"Error creating table te: %s", errorMsg);
        sqlite3_free(errorMsg);
    }
}
- (void)deleteEventType:(PerforMadEventType)eventType withCount:(NSInteger)count
{
    switch (eventType) {
        case EventLA:
        {
            char *errorMsg=NULL;
            NSString *deleteStrLA = [NSString stringWithFormat:@"DELETE FROM la WHERE row IN (SELECT row FROM la LIMIT %ld);", (long)count];
            if (sqlite3_exec (_database, [deleteStrLA  UTF8String],
                              NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(_database);
                PerforMadNSLogDebug(@"Error delete table: %s", errorMsg);
                sqlite3_free(errorMsg);
            }
            PerforMadNSLogDebug(@"delete la OK");
        }
            break;
        case EventEV:
        {
            char *errorMsg=NULL;
            NSString *deleteStrEV = [NSString stringWithFormat:@"DELETE FROM ev WHERE row IN (SELECT row FROM ev LIMIT %ld);", (long)count];
            if (sqlite3_exec (_database, [deleteStrEV  UTF8String],
                              NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(_database);
                PerforMadNSLogDebug(@"Error delete table: %s", errorMsg);
                sqlite3_free(errorMsg);
            }
            PerforMadNSLogDebug(@"delete ev OK");
        }
            break;
        case EVentTE:
        {
            char *errorMsg=NULL;
            NSString *deleteStrTE = [NSString stringWithFormat:@"DELETE FROM te WHERE row IN (SELECT row FROM te LIMIT %ld);", (long)count];
            if (sqlite3_exec (_database, [deleteStrTE  UTF8String],
                              NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(_database);
                PerforMadNSLogDebug(@"Error delete table: %s", errorMsg);
                sqlite3_free(errorMsg);
            }
            PerforMadNSLogDebug(@"delete te OK");
        }
            break;
        default:
            break;
    }
}
- (void)saveEventToDatabase:(PerforMadEventBase*)event {
    switch (event.eventType) {
        case EventLA:
        {
            char *update = "INSERT INTO la (field_data) VALUES (?);";
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(_database, update, -1, &stmt, nil) == SQLITE_OK) {
                sqlite3_bind_text(stmt, 1, [[event jsonString] UTF8String], -1, NULL);
            }
            if (sqlite3_step(stmt) != SQLITE_DONE)
            {
                PerforMadNSLogDebug(@"Error updating table la: %@", [event jsonString]);
            }
            sqlite3_finalize(stmt);
        }
            break;
        case EventEV:
        {
            char *update = "INSERT INTO ev (field_data) VALUES (?);";
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(_database, update, -1, &stmt, nil) == SQLITE_OK) {
                sqlite3_bind_text(stmt, 1, [[event jsonString] UTF8String], -1, NULL);
            }
            if (sqlite3_step(stmt) != SQLITE_DONE)
            {
                PerforMadNSLogDebug(@"Error updating table la: %@", [event jsonString]);
            }
            sqlite3_finalize(stmt);
        }
            break;
        case EVentTE:
        {
            char *update = "INSERT INTO te (field_data) VALUES (?);";
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(_database, update, -1, &stmt, nil) == SQLITE_OK) {
                sqlite3_bind_text(stmt, 1, [[event jsonString] UTF8String], -1, NULL);
            }
            if (sqlite3_step(stmt) != SQLITE_DONE)
            {
                PerforMadNSLogDebug(@"Error updating table la: %@", [event jsonString]);
            }
            sqlite3_finalize(stmt);
        }
            break;
        default:
            break;
    }
}
- (void)readEventsFromDatabaseToMemory {
    {//la
        NSString *query = @"SELECT field_data FROM la";
        sqlite3_stmt *statement=NULL;
        if (sqlite3_prepare_v2( _database, [query UTF8String],
                               -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                char *rowData = (char *)sqlite3_column_text(statement, 0);
                NSString *fieldValue = [NSString stringWithCString:rowData encoding:NSUTF8StringEncoding];
                [_laArray addObject:fieldValue];
            }
            sqlite3_finalize(statement);
        }
    }
    
    {//ev
        NSString *query = @"SELECT field_data FROM ev";
        sqlite3_stmt *statement=NULL;
        if (sqlite3_prepare_v2( _database, [query UTF8String],
                               -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *rowData = (char *)sqlite3_column_text(statement, 0);
                
                NSString *fieldValue = [NSString stringWithCString:rowData encoding:NSUTF8StringEncoding];
                [_evArray addObject:fieldValue];
            }
            sqlite3_finalize(statement);
        }
    }
    
    {//te
        NSString *query = @"SELECT field_data FROM te";
        sqlite3_stmt *statement=NULL;
        if (sqlite3_prepare_v2( _database, [query UTF8String],
                               -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *rowData = (char *)sqlite3_column_text(statement, 0);
                
                NSString *fieldValue = [NSString stringWithCString:rowData encoding:NSUTF8StringEncoding];
                [_teArray addObject:fieldValue];
            }
            sqlite3_finalize(statement);
        }
    }
}
- (void)closeDatabase
{
    if(sqlite3_exec(_database, "VACUUM;", 0, 0, NULL)==SQLITE_OK)
    {
        PerforMadNSLogDebug(@"Vacuumed DataBase");
    }
    sqlite3_close(_database);
}

@end
