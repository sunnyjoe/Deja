//
//  PerforMadTrackingCode.m
//  PerforMadTrackingCodeSample
//
//  Created by 万 永庆 on 12/9/14.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//

#import "PerforMadTrackingCode.h"
#import "PerforMadUtils.h"
#import "OpenUDID.h"
#import "PerforMadEventManager.h"
#import "PerforMadNSLog.h"
#import "PerforMadReachability.h"

#define Reactive_Mark   @"&reactivemark=1"

@interface PerforMadTrackingCode ()<PerforMadEventManagerDelegate>
{
    NSMutableArray *_arrayMillisecondsSince1970;
    PerforMadEventManager *_eventManager;
    BOOL _deActived;
    PerforMadNetworkStatus _networkType;
    BOOL _debugMode;
    NSTimeInterval _intervalGideline;
}
@property (nonatomic, copy) NSString *conversionId;
@property (nonatomic, copy) NSString *marketId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, assign) BOOL isReactive;
@end


@implementation PerforMadTrackingCode

#pragma mark single instance
static PerforMadTrackingCode *instance = NULL;
+(PerforMadTrackingCode *)instance{
    @synchronized(self){  //为了确保多线程情况下，仍然确保实体的唯一性
        if (!instance) {
            instance = [[self alloc] init]; //该方法会调用 allocWithZone
        }
    }
    return instance;
}
+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (!instance) {
            instance = [super allocWithZone:zone]; //确保使用同一块内存地址
            return instance;
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone;{
    return self; //确保copy对象也是唯一
}
#if __has_feature(objc_arc)

#else
-(id)retain{
    return self; //确保计数唯一
}
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}
- (id)autorelease
{
    return self;//确保计数唯一
}
- (oneway void)release
{
    //重写计数释放方法
}
#endif


#pragma mark Class Methods
+ (void)setCoversionId:(NSString *)conversionId{
    [self instance].conversionId = conversionId;
}

+ (void)setMarketChannel:(NSString *)marketId{
    [self instance].marketId = marketId;
}

+ (void)start:(id)currentContainer{
    [[self instance] start:currentContainer];
}

+ (void)stop:(id)currentContainer{
    [[self instance] stop:currentContainer];
}

+ (void)events:(NSString *)category action:(NSString *)action{
    [[self instance] events:category action:action];
}
+ (void)events:(NSString *)category action:(NSString *)action label:(NSString *)label{
    [[self instance] events:category action:action label:label];
}

+ (void)dispatchPolicy:(NSInteger)policy{
    [[self instance] dispatchPolicy:policy];
}
+ (void)dispatchPolicy:(NSInteger)policy isOnlyWifi:(BOOL)isOnlyWifi {
    [[self instance] dispatchPolicy:policy isOnlyWifi:isOnlyWifi];
}

+ (void)dispatch {
    [[self instance] dispatch];
}

+ (void)getCustomURLSchemes:(NSString *)url
{
    [self instance].isReactive = YES;
    if (url) {
        NSString* tempUrl=[url lowercaseString];
        NSRange sessionRange=[tempUrl rangeOfString:@"sid="];
        NSString* tempSession=nil;
        if (sessionRange.location != NSNotFound) {
            NSString* orginSessionValue=[url substringFromIndex:(sessionRange.location+sessionRange.length)];
            NSRange diviedRange=[orginSessionValue rangeOfString:@"&"];
            
            if (diviedRange.location!=NSNotFound) {
                NSString* targetSessionValue=[orginSessionValue substringToIndex:diviedRange.location];
                tempSession=targetSessionValue;
            }
            else
            {
                tempSession=orginSessionValue;
            }
            
            if (tempSession!=nil) {
#if __has_feature(objc_arc)
                NSString * encodedString =(NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)tempSession, CFSTR(""), kCFStringEncodingUTF8));
                [self instance].sessionId = encodedString;
#else
                NSString * encodedString =(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)tempSession, CFSTR(""), kCFStringEncodingUTF8);
                [self instance].sessionId = encodedString;
                if (encodedString != nil) {
                    CFRelease(encodedString);
                }
#endif
            }
            else
            {
                [self instance].sessionId = nil;
            }
            
        }
        else
        {
            [self instance].sessionId = nil;
        }
    }
    else
    {
        [self instance].sessionId = nil;
    }
}
+ (void)setDebugMode:(BOOL)debugMode {
    [[self instance] setDebugMode:debugMode];
}

#pragma mark Methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    _eventManager.delegate=nil;
#if !__has_feature(objc_arc)
    [_eventManager release],_eventManager=nil;
    [super dealloc];
#endif
}
- (id)init {
    if (![PerforMadUtils trackingEnable]) {
        return nil;
    }
    self = [super init];
    if (self) {
        _arrayMillisecondsSince1970 = [[NSMutableArray alloc] init];
        
        _eventManager = [[PerforMadEventManager alloc] init];
        _eventManager.delegate = self;
        
        _conversionId = @"";
        _marketId = nil;
        _deActived = NO;
        _debugMode = NO;
        _isReactive = NO;
        _intervalGideline = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}
- (void)setDebugMode:(BOOL)debugMode {
    _debugMode = debugMode;
}
- (void)start {
    NSTimeInterval millisecondsSince1970 = [self millisecondsSince1970];
    [_arrayMillisecondsSince1970 addObject:[NSString stringWithFormat:@"%f", millisecondsSince1970]];
    NSString *utc = [self  utc];
    PerforMadEventLA *la = [[PerforMadEventLA alloc] init];
    la.utc = utc;
    la.sessionId = [self realSessionId];
    la.aas = [self getAAS];
    [_eventManager addEvent:la];
#if !__has_feature(objc_arc)
    [la release],la=nil;
#endif
}
- (void)start:(id)currentContainer {
    NSTimeInterval millisecondsSince1970 = [self millisecondsSince1970];
    [_arrayMillisecondsSince1970 addObject:[NSString stringWithFormat:@"%f", millisecondsSince1970]];
    NSString *utc = [self  utc];
    PerforMadEventLA *la = [[PerforMadEventLA alloc] init];
    la.utc = utc;
    la.sessionId = [self realSessionId];
    la.aas = [self getAAS];
    [_eventManager addEvent:la];
#if !__has_feature(objc_arc)
    [la release],la=nil;
#endif
}

- (void)stop{
    NSInteger duration = 0;
    NSString *t = [_arrayMillisecondsSince1970 lastObject];
    if (t != nil) {
        NSTimeInterval millisecondsSince1970 = [t doubleValue];
        [_arrayMillisecondsSince1970 removeLastObject];
        duration = ([self millisecondsSince1970] - millisecondsSince1970)/1000;
    }
    
    
    NSString *utc = [self  utc];
    PerforMadEventTE *te = [[PerforMadEventTE alloc] init];
    te.utc = utc;
    te.sessionId = [self realSessionId];
    te.duration = duration;
    te.controller = NSStringFromClass([[PerforMadTrackingCode getTopMostViewController] class]);
    [_eventManager addEvent:te];
#if !__has_feature(objc_arc)
    [te release],te=nil;
#endif
}
- (void)stop:(id)currentContainer{
    NSInteger duration = 0;
    NSString *t = [_arrayMillisecondsSince1970 lastObject];
    if (t != nil) {
        NSTimeInterval millisecondsSince1970 = [t doubleValue];
        [_arrayMillisecondsSince1970 removeLastObject];
        duration = ([self millisecondsSince1970] - millisecondsSince1970)/1000;
    }
    
    NSString *utc = [self  utc];
    PerforMadEventTE *te = [[PerforMadEventTE alloc] init];
    te.utc = utc;
    te.sessionId = [self realSessionId];
    te.duration = duration;
    te.controller = NSStringFromClass([currentContainer class]);
    [_eventManager addEvent:te];
#if !__has_feature(objc_arc)
    [te release],te=nil;
#endif
}

- (void)events:(NSString *)category action:(NSString *)action {
    [self events:category action:action label:nil];
}
- (void)events:(NSString *)category action:(NSString *)action label:(NSString *)label{
    [self events:category action:action label:label value:Value_None];
}
- (void)events:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    NSString *utc = [self utc];
    PerforMadEventEV *ev = [[PerforMadEventEV alloc] init];
    ev.utc = utc;
    ev.sessionId = [self realSessionId];
    ev.categary = category;
    ev.action = action;
    ev.label = label;
    ev.value = value;
    [_eventManager addEvent:ev];
#if !__has_feature(objc_arc)
    [ev release],ev=nil;
#endif
}


- (void)dispatchPolicy:(NSInteger)policy {
    [self dispatchPolicy:policy isOnlyWifi:NO];
}
- (void)dispatchPolicy:(NSInteger)policy isOnlyWifi:(BOOL)isOnlyWifi{
    _eventManager.policy = policy;
    _eventManager.onlyWifi = isOnlyWifi;
    if (policy > POLICY_REAL) {
        [_eventManager startTimer];
    }
    else {
        [_eventManager stopTimer];
    }
}

- (void)dispatch {
    [_eventManager dispatch];
}

- (NSString*)encryptForTransmission:(NSString*)aStr {
    NSData *data = [aStr dataUsingEncoding: NSASCIIStringEncoding];
    NSString* str=[PerforMadUtils base64StringFromData:data length:[data length]];
    return [PerforMadUtils exchangePosition:str];
}

- (NSString*)getNetworkType {
    switch ([self currentNetworkType]) {
        case PerforMadNetwork_2G:
            return @"0";
            break;
        case PerforMadNetwork_3G:
            return @"2";
            break;
        case PerforMadNetwork_4G:
            return @"4";
            break;
        case PerforMadNetwork_Wifi:
            return @"3";
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

- (NSInteger)getAAS {
    NSString *path = [PerforMadUtils markTrackingCodeFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString*  fileContent=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if([fileContent isEqualToString:StatusCode_Success])
        {
            if ([self isAppJustUpdated]) {
                [@"2" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                return 2;
            }
            else {
                return 0;
            }
        }
        else{
            return 0;
        }
    }
    else {
        [@"1" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return 1;
    }
}
-(BOOL)isAppJustUpdated
{
    NSString* currentVersion=[PerforMadUtils ApplicationVersion];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[PerforMadUtils markTrackingCodeAppVersionFile]]) {
        NSString*  fileContent=[NSString stringWithContentsOfFile:[PerforMadUtils markTrackingCodeAppVersionFile] encoding:NSUTF8StringEncoding error:nil];
        if (![currentVersion isEqualToString:fileContent]) {
            return YES;
        }
    }
    return NO;
}
- (NSTimeInterval)millisecondsSince1970 {
    return [[NSDate date] timeIntervalSince1970]*1000;
}
-(NSString*)utc {
    return [NSString stringWithFormat:@"%.0f%@", [self millisecondsSince1970], [PerforMadUtils gmt]];
}

- (NSString*)realConversionId {
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *plistConversionId = [infoDict objectForKey:SM_CONVERSION_ID];
    if (plistConversionId!=nil) {
        return plistConversionId;
    }
    else
        return self.conversionId;
}
- (NSString*)realSessionId {
    if (self.sessionId != nil) {
        if ([self isSessionIdExpired]) {
            self.sessionId = nil;
        }
    }
    return self.sessionId;
}
- (BOOL)isSessionIdExpired {
    if (_intervalGideline == 0) {
        _intervalGideline = [[NSDate date] timeIntervalSince1970];
        return NO;
    }
    else {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        if (interval - _intervalGideline > _eventManager.expiredMax) {
            _intervalGideline = interval;
            return YES;
        }
        else {
            _intervalGideline = interval;
            return NO;
        }
    }
}
- (NSString*)parametersOfLaunch
{
    NSMutableString * mutableString = [[NSMutableString alloc] init];
    [PerforMadUtils addKey:@"?pv=" assignValue:[PerforMadUtils SDKVersion] for:mutableString];
    if (_debugMode)
        [mutableString appendString:@"&db=1"];
    NSString *conversionId = [self realConversionId];
    if (conversionId == nil)
        conversionId = @"";
    [PerforMadUtils addKey:@"&cid=" assignValue:conversionId for:mutableString];
    NSString *sessionId = [self realSessionId];
    if (sessionId != nil) {
        [PerforMadUtils addKey:@"&sid=" assignValue:sessionId for:mutableString];
    }
    if ([PerforMadUtils overIOS6]) {
        if ([PerforMadUtils isAdvertisingTrackingEnabled]) {
            NSString *aid = [PerforMadUtils IDFAIdentity];
            if (aid != nil) {
                [PerforMadUtils addKey:@"&aid=" assignValue:[self encryptForTransmission:aid] for:mutableString];
            }
        }
    }
    else {
        NSString *oid = [OpenUDID value];
        if (oid != nil) {
            [PerforMadUtils addKey:@"&oid=" assignValue:[self encryptForTransmission:oid] for:mutableString];
        }
    }
    if (self.marketId != nil) {
        [PerforMadUtils addKey:@"&hid=" assignValue:self.marketId for:mutableString];
    }
    [PerforMadUtils addKey:@"&mod=" assignValue:[PerforMadUtils platform] for:mutableString];
    NSString *nt = [self getNetworkType];
    [PerforMadUtils addKey:@"&nt=" assignValue:nt for:mutableString];
    NSString *cn = [PerforMadUtils carrierName];
    if (cn != nil && ![cn isEqualToString:@""]) {
        [PerforMadUtils addKey:@"&cn=" assignValue:cn for:mutableString];
    }
    NSString *bssid = [PerforMadUtils BSSID];
    if (bssid != nil) {
        [PerforMadUtils addKey:@"&bss=" assignValue:bssid for:mutableString];
    }
    [mutableString appendString:@"&os=1"];
    [PerforMadUtils addKey:@"&osv=" assignValue:[PerforMadUtils PlatformVersion] for:mutableString];
    [PerforMadUtils addKey:@"&lng=" assignValue:[PerforMadUtils PlatformLanguage] for:mutableString];
    NSString* jb=[PerforMadUtils isJailbreak];
    if (jb != nil) {
        [PerforMadUtils addKey:@"&jb=" assignValue:jb for:mutableString];
    }
    [PerforMadUtils addKey:@"&de=" assignValue:[PerforMadUtils isEmulator] for:mutableString];
    [PerforMadUtils addKey:@"&apn=" assignValue:[PerforMadUtils ApplicationPackageName] for:mutableString];
    [PerforMadUtils addKey:@"&av=" assignValue:[PerforMadUtils ApplicationVersion] for:mutableString];
    if (self.isReactive) {
        [mutableString appendString:Reactive_Mark];
    }
#if !__has_feature(objc_arc)
    return [mutableString autorelease];
#else
    return mutableString;
#endif
}
- (NSString*)parametersForNormal {
    NSMutableString * mutableString = [[NSMutableString alloc] init];
    [PerforMadUtils addKey:@"?pv=" assignValue:[PerforMadUtils SDKVersion] for:mutableString];
    if (_debugMode)
        [mutableString appendString:@"&db=1"];
    
    NSString *sessionId = [self realSessionId];
    if (sessionId != nil) {
        [PerforMadUtils addKey:@"&sid=" assignValue:sessionId for:mutableString];
    }
    [mutableString appendString:@"&os=1"];
#if !__has_feature(objc_arc)
    return [mutableString autorelease];
#else
    return mutableString;
#endif
}

#pragma mark PerforMadEventManagerDelegate
- (NSString*)parametersOfUrl {
    NSString *sessionId = [self realSessionId];
    if (self.isReactive || sessionId == nil) {
        return [self parametersOfLaunch];
    }
    else {
        return [self parametersForNormal];
    }
}

- (void)changeSessionId:(NSString*)sessionId{
    self.sessionId = sessionId;
}
- (PerforMadNetworkStatus)currentNetworkType {
    PerforMadReachability *reachWifi = [PerforMadReachability reachabilityForLocalWiFi];
    _networkType = [reachWifi currentReachabilityStatus];
    return _networkType;
}
- (void)onSendOK:(NSString*)urlString {
    NSRange range = [urlString rangeOfString:Reactive_Mark];
    if (range.location != NSNotFound) {
        self.isReactive = NO;
    }
}
- (BOOL)canSend {
//    return !_deActived; //切换到后台则不发送
    return YES;
}
#pragma mark ViewController

+ (UIViewController*) getTopMostViewController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
    for (UIView *subView in [window subviews])
    {
        UIResponder *responder = [subView nextResponder];
        
        //added this block of code for iOS 8 which puts a UITransitionView in between the UIWindow and the UILayoutContainerView
        if ([responder isEqual:window])
        {
            //this is a UITransitionView
            if ([[subView subviews] count])
            {
                UIView *subSubView = [subView subviews][0]; //this should be the UILayoutContainerView
                responder = [subSubView nextResponder];
            }
        }
        
        if([responder isKindOfClass:[UIViewController class]]) {
            return _topMostController((UIViewController *) responder);
        }
    }
    
    return nil;
}

UIViewController *_topMostController(UIViewController *cont) {
    UIViewController *topController = cont;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
            topController = visible;
        }
    }
    else if ([topController isKindOfClass:[UITabBarController class]]) {
        UIViewController *visible = ((UITabBarController *)topController).selectedViewController;
        if (visible) {
            topController = visible;
        }
    }
    
    return topController;
}
#pragma mark SystemNotification
- (void)applicationDidBecomeActive {
    if (_deActived) {
        _deActived = NO;
    }
    [self start];
}
- (void)applicationWillResignActive {
    _deActived = YES;
    [_eventManager stopTimer];
    [self stop];
}
@end
