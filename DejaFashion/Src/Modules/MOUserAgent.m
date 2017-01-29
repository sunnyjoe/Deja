//
//  MOUserAgent.m
//  DejaFashion
//
//  Created by Sun lin on 22/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "MOUserAgent.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "OpenUDID.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MOUserAgent
{
    NSString *userAgent;
    NSString* bundleRevision;
    NSString *fullVersionString;
    NSString* languageCode;
    NSString *clientVersion;
    NSString* deviceid;

}



static MOUserAgent *sharedInstance;
+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

-(id)init
{
    // TODO (JIAOQING) CHANGED FROM singleton class to non
    NSAssert(!sharedInstance, @"This should be a singleton class.");
    self = [super init];
    if(self)
    {
        
    }
    return self;
    
}

-(NSString*)userAgent
{
    
    @synchronized(self)
    {
        
        if(!userAgent) // this is inside critical section is necessary
        {
            int caps = [self clientCapability];
            CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *carrier = [netInfo subscriberCellularProvider];
            NSString *mcc = carrier.mobileCountryCode;
            NSString *mnc = carrier.mobileNetworkCode;
//
            NSMutableString *temp = [[NSMutableString alloc] init];
            
            
            
            ;
            [temp appendFormat:@"iOS/%@",[self stringByEncodingAsUserAgent:[self platformVersion]]];
            [temp appendFormat:@" CiOS/%@",[self bundleRevision]];
            [temp appendFormat:@" Encoding/%@",@"UTF-8"];
//            [temp appendFormat:@" Locale/%@",[locale localeIdentifier]];
            [temp appendFormat:@" Lang/%@",[self languageCode]];
            [temp appendFormat:@" Morange/%@",[self clientVersion]];
            [temp appendFormat:@" Caps/%d",caps];
            [temp appendFormat:@" PI/%@",[self deviceID]];
            [temp appendFormat:@" Domain/%@",[self userDomainWithoutAt]];
            [temp appendFormat:@" DeviceBrand/%@",@"Apple"];
            NSString *model = machineName() ? : ([self platformName]);
            [temp appendFormat:@" DeviceModel/%@",[self stringByEncodingAsUserAgent:model]];
            [temp appendFormat:@" DeviceVersion/%@",[self stringByEncodingAsUserAgent:[self platformVersion]]];
            [temp appendFormat:@" ClientType/%@",@"CiOS"];
            [temp appendFormat:@" ClientBuild/%@",[self fullVersionString]];
            [temp appendFormat:@" appID/%@",[self appIdentifier]];
            [temp appendFormat:@" ScreenWidth/%d",(int)([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale)];
            [temp appendFormat:@" ScreenHeight/%d",(int)([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale)];
            [temp appendFormat:@" Mcc/%@", mcc];
            [temp appendFormat:@" Mnc/%@", mnc];
            userAgent = [[NSString alloc] initWithString:temp];
        }
    }
    return userAgent;
}

-(NSString *)appIdentifier
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

-(NSString*)languageCode
{
    if(!languageCode)
    {
        languageCode = nil;
        NSString* pricipleLanguageCode = @"en";
        NSArray* languages = [NSLocale preferredLanguages];
        NSString* systemLanguageCode = pricipleLanguageCode;
        
        if(languages.count > 0)
        {
            NSString* code = [languages objectAtIndex:0];
            
            // must be converted right away
            //http://wiki.mozat.com/en/doku.php?id=client_user_agent#language_code
            //			if([code isEqual:@"zh-Hans"])
            //			{
            //				code = @"zh-CN";
            //			}
            //			else if([code isEqual:@"zh-Hant"])
            //			{
            //				code = @"zh-TW";
            //			}
            
            languageCode = code;
            systemLanguageCode = languageCode;
        }
        else
        {
            languageCode = pricipleLanguageCode;
        }
        
        // must be a supported language, otherwise fallback to principle
//        if(![supportedLanguages containsObject:self._languageCode])
//        {
//            languageCode = pricipleLanguageCode;
//        }
    }
    return languageCode;
}

-(NSString*)bundleRevision
{
    [self initializeVersionStrings];
    return bundleRevision;
}

-(NSString*)fullVersionString
{
    [self initializeVersionStrings];
    return fullVersionString;
}

-(void)initializeVersionStrings
{
    @synchronized(self)
    {
        if(!fullVersionString)
        {
            fullVersionString = [[NSBundle mainBundle]  objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            fullVersionString = [NSString stringWithFormat:@"%@.%@", fullVersionString, [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
            NSRange range = [fullVersionString rangeOfString:@"." options:NSBackwardsSearch];
            if(range.location != NSNotFound)
            {
                clientVersion = [fullVersionString substringToIndex:range.location];
                bundleRevision = [fullVersionString substringFromIndex:range.location + 1];
            }
            else
            {
                clientVersion = @"2.0.0";
                bundleRevision = @"0";
            }
        }
    }
}

-(NSString*)stringByEncodingAsUserAgent:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return str;
}



-(int)clientCapability
{
    return 0;
}


-(NSString*)platformVersion {
    return [[UIDevice currentDevice] systemVersion];
}

-(int)platformVersionOfInt
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(int)platformType {
    return 8;
}

-(NSString*)clientType {
    return @"CiOS";
}

-(NSString*)defaultEncoding {
    return @"UTF-8";
}

-(NSString*)localeIdentifier {
    return [[NSLocale currentLocale] localeIdentifier];
}

-(NSString*)platformName {
    return [[UIDevice currentDevice] model];
}

-(NSString*)clientVersion
{
    [self initializeVersionStrings];
    return clientVersion;
}
               

-(NSString*)userDomainWithoutAt
{
    NSDictionary *configDict = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MOAppConfig"];
    NSString *usernameSuffixLocal = [configDict objectForKey:@"UsernameSuffix"];
    if(usernameSuffixLocal &&
       usernameSuffixLocal.length > 0 &&
       [usernameSuffixLocal characterAtIndex:0] == '@')
    {
        return [usernameSuffixLocal substringFromIndex:1];
    }
    
    return usernameSuffixLocal;
}


-(NSString*)deviceID
{
    if(!deviceid)
    {
        NSString* udid;
//        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_5_1)
//            udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
//        else
            udid = [OpenUDID value];
        
        // the format string CANNOT be changed after first release
        NSString* mystifiy = [NSString stringWithFormat:@"PHONE%@ID%@OBFUST", udid, udid];
        deviceid = MOMD5HexString(mystifiy);
    }
    return deviceid;
}


NSString *machineName()
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",      // (Original)
                              @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                              @"iPhone1,1" :@"iPhone",          // (Original)
                              @"iPhone1,2" :@"iPhone",          // (3G)
                              @"iPhone2,1" :@"iPhone",          // (3GS)
                              @"iPad1,1"   :@"iPad",            // (Original)
                              @"iPad2,1"   :@"iPad 2",          //
                              @"iPad3,1"   :@"iPad",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        //
                              @"iPhone4,1" :@"iPhone 4S",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",            // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",       // (Original)`
                              @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 plus",       //
                              @"iPhone7,2" :@"iPhone 6",       //
                              @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini"        // (2nd Generation iPad Mini - Cellular)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
    }
    
    return deviceName;
}


NSString* MOMD5HexString(NSString* str)
{
    Byte result[16];
    MOMD5(str, result);
    NSMutableString* hex = [NSMutableString stringWithCapacity:32];
    for(int i = 0; i < 16; ++i)
    {
        [hex appendFormat:@"%02x", result[i]];
    }
    return hex;
}

void MOMD5(NSString* str, Byte result[])
{
    CC_MD5([str UTF8String], (CC_LONG)[str lengthOfBytesUsingEncoding:NSUTF8StringEncoding], result);
}



@end
