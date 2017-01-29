//
//  PerforMadUtils.h
//  TrackingCodeSample
//
//  Created by RobertChow on 13-9-27.
//  Copyright (c) 2015 Madhouse Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


#define StatusCode_Success		@"200"
#define StatusCode_Closure		@"403"

#define PREFIX_NAME				@"PerforMad"
#define SDKVERSION				@"2.0.2"
#define SleepTrackingCodeFile   @"SleepTrackingCodeFile"
#define AppVersionFile			@"AppVersionFile"
#define DatabaseFile			@"DatabaseFile"
#define SERVER_URL				@"http://cn.track.onemad.com/services/sendEvt"

@interface PerforMadUtils : NSObject  

+(NSString*)DeviceModel;
+(NSString*)PlatformType;
+(NSString*)PlatformVersion;
+(NSString*)PlatformLanguage;
+(NSString*)ApplicationPackageName;
+(NSString*)ApplicationVersion;
+(NSString*)SDKVersion;
+ (NSString*)databaseFileName;
+ (BOOL)trackingEnable;
+(NSString*)markTrackingCodeFileName;
+(NSString*)markTrackingCodeAppVersionFile;
+(NSString *) platform;

+ (NSString *) base64StringFromData:(NSData *)data length:(NSInteger)length;
+(NSString*)exchangePosition:(NSString*)aStr;
+ (NSString*)ua;
+ (BOOL)isAdvertisingTrackingEnabled ;
+(NSString*)IDFAIdentity;
+(NSString*)isJailbreak;

+(NSString*)isEmulator;
+(NSString*)carrierName;
+ (BOOL)overIOS6;
+(BOOL)overIOS7;
+ (NSString*)BSSID;
+ (NSString *)gmt;
+ (void)addKey:(NSString *)key assignValue:(NSString *)value for:(NSMutableString*)aStr ;
@end
