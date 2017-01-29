//
//  SmartMadUtils.m
//  TrackingCodeSample
//
//  Created by RobertChow on 13-9-27.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreFoundation/CoreFoundation.h>
#import "PerforMadUtils.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <UIKit/UIKit.h>

//#define kShouldPrintSMNetEngineFlags 1

static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};


@implementation PerforMadUtils


+ (NSString *) base64StringFromData: (NSData *)data length: (NSInteger)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}
+(NSString*)exchangePosition:(NSString*)aStr
{
    char* data=(char*)[[aStr dataUsingEncoding:NSASCIIStringEncoding] bytes];
    NSInteger strLen=[aStr length];
    int num = 0;
    while (num < strLen)
    {
        char temp = data[num];
        data[num] = data[num + 1];
        data[num + 1] = temp;
        num += 2;
        if((strLen%2!=0)&&(num==strLen-1))
            break;
    }
    NSData* byteData = [NSData dataWithBytes:data length:[aStr length]];
#if __has_feature(objc_arc)
    return [[NSString alloc]  initWithBytes:[byteData bytes]
                                     length:[byteData length] encoding: NSASCIIStringEncoding];
#else
    return [[[NSString alloc]  initWithBytes:[byteData bytes]
                                      length:[byteData length] encoding: NSASCIIStringEncoding] autorelease];
#endif
}

+ (NSString*)ua
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
#if __has_feature(objc_arc)
    ;
#else
    [webView release];
#endif
    return secretAgent;
}


+(NSString*)DeviceModel{
    return [[UIDevice currentDevice] model];
}
+(NSString*)PlatformType{
    return @"1";
}
+(NSString*)PlatformVersion{
    return [[UIDevice currentDevice] systemVersion];
}
+(NSString*)PlatformLanguage{
    NSLocale* locale = [NSLocale currentLocale];
    NSString* countryCode = [locale objectForKey:NSLocaleCountryCode];
    NSString* languageCode = [locale objectForKey:NSLocaleLanguageCode];
    NSString* lng=nil;
    if (languageCode) {
        lng=[NSString stringWithFormat:@"%@_%@",languageCode,countryCode];
        return lng;
    }
    return nil;
}
+(NSString*)ApplicationPackageName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}
+(NSString*)ApplicationVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}
+(NSString*)SDKVersion{
    return SDKVERSION;
}
+(NSString*)markTrackingCodeFileName
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", SleepTrackingCodeFile, PREFIX_NAME]];
}
+ (BOOL)trackingEnable {
    NSString *fileName = [PerforMadUtils markTrackingCodeFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSString*  fileContent=[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
        if ([fileContent isEqualToString:StatusCode_Closure]) {
            return NO;
        }
    }
    return YES;
}
+(NSString*)markTrackingCodeAppVersionFile
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",AppVersionFile, PREFIX_NAME]];
}
+ (NSString*)databaseFileName {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", DatabaseFile, PREFIX_NAME]];
}

+(NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}


+(NSString*)isEmulator
{
#if TARGET_IPHONE_SIMULATOR
    return @"0";
#elif TARGET_OS_IPHONE
    return @"1";
#endif
}

+(NSString*)carrierName
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
#if __has_feature(objc_arc)
    ;
#else
    [netInfo release];
#endif
    
    NSString *carrierCode;
    
    if (carrier == nil) {
        
        carrierCode = @"WiFi"; // 未取到，暂用WiFi代替
        
    }
    
    else {
        
        carrierCode = [carrier carrierName];
        
    }
    
    return carrierCode;
}
+ (BOOL)overIOS6 {
    NSInteger version = [[[UIDevice currentDevice] systemVersion] floatValue] *100;
    if (version >= 600) {
        return YES;
    }
    return NO;
}

+(BOOL)overIOS7
{
    NSInteger version = [[[UIDevice currentDevice] systemVersion] floatValue] *100;
    if (version >= 700) {
        return YES;
    }
    return NO;
}
+(NSString*)IDFAIdentity
{
    if ([self overIOS6]) {
        return [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    }
    return nil;
    
}
+ (BOOL)isAdvertisingTrackingEnabled {
    if ([self overIOS6]) {
        return [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled;
    }
    return NO;
}


+(NSString*)isJailbreak{
#if TARGET_IPHONE_SIMULATOR
    return nil;
#else
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    if (jailbroken) {
        return @"1";
    }
    return nil;
#endif
}

+ (NSString*)BSSID {
#if TARGET_IPHONE_SIMULATOR
    return nil;
#elif TARGET_OS_IPHONE
    NSString *bssid = nil;
#if !__has_feature(objc_arc)
    NSArray *ifs = (id)CNCopySupportedInterfaces();
#else
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
#endif
    //    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
#if !__has_feature(objc_arc)
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
#else
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
#endif
        //        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            if (info[@"BSSID"]) {
                NSString *temp = info[@"BSSID"];
                BOOL isStartWith0 = NO;
                if (temp != nil) {
                    NSArray *array = [temp componentsSeparatedByString:@":"];
                    if ([[array objectAtIndex:0] integerValue] == 0) {
                        isStartWith0 = YES;
                    }
                }
                if (isStartWith0) {
                    bssid = [[NSString stringWithFormat:@"0%@", temp] stringByReplacingOccurrencesOfString:@":" withString:@""];
                }
                else {
                    bssid = [temp stringByReplacingOccurrencesOfString:@":" withString:@""];
                }
            }
            break;
        }
#if !__has_feature(objc_arc)
        [info release];
#endif
    }
#if !__has_feature(objc_arc)
    [ifs release];
#endif
    return bssid;
#endif
}

+(NSString *)gmt
{
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMT];
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSInteger gmtGMTOffset = [gmtTimeZone secondsFromGMT];
    NSInteger offset = (currentGMTOffset - gmtGMTOffset)/3600;
    
    if (offset >= 0) {
        return [NSString stringWithFormat:@"+%ld", (long)offset];
    }
    else
        return [NSString stringWithFormat:@"%ld", (long)offset];
}
+ (void)addKey:(NSString *)key assignValue:(NSString *)value for:(NSMutableString*)aStr {
#if __has_feature(objc_arc)
    NSString * encodedString = (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)value, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 ));
#else
    NSString * encodedString = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)value, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
#endif
    [aStr appendFormat:@"%@%@", key, encodedString];
#if __has_feature(objc_arc)
    ;
#else
    CFRelease(encodedString);
#endif
}
@end

