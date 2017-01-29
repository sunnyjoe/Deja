/*
 
 File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 
 Version: 2.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "PerforMadReachability.h"

#define SMAD_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define kPerforMadShouldPrintReachabilityFlags 1

#define PerforMad_CTRadioAccessTechnologyGPRS            @"gprs"
#define PerforMad_CTRadioAccessTechnologyEdge            @"edge"
#define PerforMad_CTRadioAccessTechnologyWCDMA           @"wcdma"
#define PerforMad_CTRadioAccessTechnologyHSDPA           @"hsdpa"
#define PerforMad_CTRadioAccessTechnologyHSUPA           @"hsupa"
#define PerforMad_CTRadioAccessTechnologyCDMA1x          @"cdma1x"
#define PerforMad_CTRadioAccessTechnologyCDMAEVDORev0    @"cdmaevdorev0"
#define PerforMad_CTRadioAccessTechnologyCDMAEVDORevA    @"cdmaevdoreva"
#define PerforMad_CTRadioAccessTechnologyCDMAEVDORevB    @"cdmaevdorevb"
#define PerforMad_CTRadioAccessTechnologyeHRPD           @"hrpd"
#define PerforMad_CTRadioAccessTechnologyLTE             @"lte"

static PerforMadNetworkStatus   gNetStatus=PerforMadNetwork_None;
static PerforMadNetworkStatus   gTelephoneStatus=PerforMadNetwork_None;
static CTTelephonyNetworkInfo* gNetworkInfo=nil;

@interface PerforMadReachability ()

@property (nonatomic, strong) CTTelephonyNetworkInfo* networkInfo;
@property (nonatomic, assign)SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, assign)BOOL localWiFiRef;

@end

static void PrintReachabilityFlags(SCNetworkReachabilityFlags    flags, const char* comment)
{
}


@implementation PerforMadReachability
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
#if !__has_feature(objc_arc)
    NSCAssert([(NSObject*) info isKindOfClass: [PerforMadReachability class]], @"info was wrong class in ReachabilityCallback");
    
    //We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someon uses the Reachablity object in a different thread.
    NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];
    
    PerforMadReachability* noteObject = (PerforMadReachability*) info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kPerforMadReachabilityChangedNotification object: noteObject];
    
    [myPool release];
#else
    //We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someon uses the Reachablity object in a different thread.
    @autoreleasepool {
        PerforMadReachability* noteObject = (__bridge PerforMadReachability*) info;
        // Post a notification to notify the client that the network reachability changed.
        [[NSNotificationCenter defaultCenter] postNotificationName: kPerforMadReachabilityChangedNotification object: noteObject];
    }
    
#endif
}



- (BOOL) startNotifier
{
    
    BOOL retVal = NO;
#if !__has_feature(objc_arc)
    SCNetworkReachabilityContext	context = {0, self, NULL, NULL, NULL};
#else
    SCNetworkReachabilityContext	context = {0, (__bridge void *)(self), NULL, NULL, NULL};
#endif
    if(SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context))
    {
        if(SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            retVal = YES;
        }
    }
    return retVal;
    
    
}


- (void) stopNotifier
{
    if(self.reachabilityRef!= NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
    
    if (SMAD_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CTRadioAccessTechnologyDidChangeNotification object:nil];
    }
    
}

- (void) dealloc
{
    [self stopNotifier];
    if(self.reachabilityRef!= NULL)
    {
        CFRelease(self.reachabilityRef);
    }
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

+ (PerforMadReachability*) reachabilityWithHostName: (NSString*) hostName;
{
    PerforMadReachability* retVal = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if(reachability!= NULL)
    {
#if !__has_feature(objc_arc)
        retVal= [[[self alloc] init] autorelease];
#else
        retVal = [[self alloc] init];
#endif
        if(retVal!= NULL)
        {
            retVal.reachabilityRef = reachability;
            retVal.localWiFiRef = NO;
        }
    }
    
    if (retVal) {
        [retVal addTelephoneInfoDetector];
    }
    
    return retVal;
    
}

-(void)addTelephoneInfoDetector
{
    if (SMAD_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (gNetworkInfo==nil) {
            gNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        }
        gTelephoneStatus = [self networkStatusFromTelephoneInfo:[gNetworkInfo.currentRadioAccessTechnology lowercaseString]];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(radioAccessChanged)
                                                     name: CTRadioAccessTechnologyDidChangeNotification
                                                   object:nil];
    }
}

+ (PerforMadReachability*) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress;
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    PerforMadReachability* retVal = NULL;
    if(reachability!= NULL)
    {
#if !__has_feature(objc_arc)
        retVal= [[[self alloc] init] autorelease];
#else
        retVal = [[self alloc] init];
#endif
        if(retVal!= NULL)
        {
            retVal.reachabilityRef = reachability;
            retVal.localWiFiRef = NO;
        }
    }
    
    if (retVal) {
        [retVal addTelephoneInfoDetector];
    }
    
    return retVal;
}

+ (PerforMadReachability*) reachabilityForInternetConnection;
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self reachabilityWithAddress: &zeroAddress];
}

+ (PerforMadReachability*) reachabilityForLocalWiFi;
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    PerforMadReachability* retVal = [self reachabilityWithAddress: &localWifiAddress];
    if(retVal!= NULL)
    {
        retVal.localWiFiRef = YES;
    }
    return retVal;
}

#pragma mark Network Flag Handling

- (PerforMadNetworkStatus) localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    PrintReachabilityFlags(flags, "localWiFiStatusForFlags");
    
    BOOL retVal = PerforMadNetwork_None;
    if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
    {
        retVal = PerforMadNetwork_Wifi;
    }
    return retVal;
}

- (PerforMadNetworkStatus) PerforMadNetworkStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    PrintReachabilityFlags(flags, "PerforMadNetworkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // if target host is not reachable
        return PerforMadNetwork_None;
    }
    
    BOOL retVal = PerforMadNetwork_None;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = PerforMadNetwork_Wifi;
    }
    
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = PerforMadNetwork_Wifi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        //retVal = ReachableViaWWAN;
        
        // temp
        
        if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
            
            retVal = PerforMadNetwork_3G;
            
            if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                
                retVal = PerforMadNetwork_2G;
                
            }
            
        }
        
    }
    return retVal;
}

- (BOOL) connectionRequired;
{
    NSAssert(self.reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

-(PerforMadNetworkStatus)networkStatusFromTelephoneInfo:(NSString*)currentRadioAccessTechnology
{
    NSString* status =[currentRadioAccessTechnology lowercaseString];
    PerforMadNetworkStatus  smStatus = PerforMadNetwork_None;
    if(([status rangeOfString:PerforMad_CTRadioAccessTechnologyGPRS].length>0) || ([status rangeOfString:PerforMad_CTRadioAccessTechnologyEdge].length>0)|| ([status rangeOfString:PerforMad_CTRadioAccessTechnologyCDMA1x].length>0)){
        smStatus = PerforMadNetwork_2G;
    }
    if(([status rangeOfString:PerforMad_CTRadioAccessTechnologyWCDMA].length>0) || ([status rangeOfString:PerforMad_CTRadioAccessTechnologyHSDPA].length>0)|| ([status rangeOfString:PerforMad_CTRadioAccessTechnologyHSUPA].length>0)|| ([status rangeOfString:PerforMad_CTRadioAccessTechnologyeHRPD].length>0)|| ([status rangeOfString:PerforMad_CTRadioAccessTechnologyCDMAEVDORev0].length>0)|| ([status rangeOfString:PerforMad_CTRadioAccessTechnologyCDMAEVDORevA].length>0)|| ([status rangeOfString:PerforMad_CTRadioAccessTechnologyCDMAEVDORevB].length>0)){
        smStatus = PerforMadNetwork_3G;
    }
    if([status rangeOfString:PerforMad_CTRadioAccessTechnologyLTE].length>0){
        smStatus = PerforMadNetwork_4G;
    }
    
    return smStatus;
}

- (void)radioAccessChanged
{
    NSString*  status = [gNetworkInfo.currentRadioAccessTechnology lowercaseString];
    gTelephoneStatus = [self networkStatusFromTelephoneInfo:status];
    
    
}

- (PerforMadNetworkStatus) currentReachabilityStatus
{
    NSAssert(self.reachabilityRef != NULL, @"currentPerforMadNetworkStatus called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        if(self.localWiFiRef)
        {
            gNetStatus = [self localWiFiStatusForFlags: flags];
        }
        else
        {
            gNetStatus = [self PerforMadNetworkStatusForFlags: flags];
        }
    }
    
    if (SMAD_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")&&(gNetStatus!=PerforMadNetwork_Wifi)) {
        if ((gTelephoneStatus ==PerforMadNetwork_2G) ||(gTelephoneStatus ==PerforMadNetwork_3G) ||(gTelephoneStatus ==PerforMadNetwork_4G)  ) {
            return gTelephoneStatus;
        }
    }
    return gNetStatus;
}
@end
