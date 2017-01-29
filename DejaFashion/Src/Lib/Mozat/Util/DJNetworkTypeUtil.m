//
//  DJNetworkTypeUtil.m
//  DejaFashion
//
//  Created by Kevin Lin on 22/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJNetworkTypeUtil.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation DJNetworkTypeUtil

+ (NSString *)networkType
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    switch (reachability.currentReachabilityStatus) {
        case ReachableViaWiFi:
            return @"wifi";
        case NotReachable:
            return @"na";
        case ReachableViaWWAN: {
            CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadio = telephonyInfo.currentRadioAccessTechnology;
            if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
                return @"4g";
                
            } else if([currentRadio isEqualToString:CTRadioAccessTechnologyEdge]) {
                return @"2g";
                
            } else if([currentRadio isEqualToString:CTRadioAccessTechnologyWCDMA]){
                return @"3g";
                
            }
        }
            break;
        default:
            break;
    }
    return @"unknown";
}

@end
