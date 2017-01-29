//
//  DJSetDeviceSettingNetTask.m
//  DejaFashion
//
//  Created by Sun lin on 28/5/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJSetDeviceSettingNetTask.h"
#import "DJConfigDataContainer.h"

@implementation DJSetDeviceSettingNetTask

- (NSString *)uri
{
    return @"/apis_bm/account_setting/set_push_noti_property/v4";
}

- (DJHTTPNetTaskMethod)method
{
    return DJHTTPNetTaskPost;
}

- (NSDictionary *)query
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:[DJConfigDataContainer instance].pushControlDealAlertOn ? @(1) : @(0) forKey:@"deal_alert"];
    
//    NSDictionary *que = [NSDictionary dictionaryWithObjectsAndKeys:dictionary, @"push_noti", nil];
    return dictionary;
}

- (void)didResponseJSON:(NSDictionary *)response
{
    
}

- (void)didFail:(NSError *)error
{
    
}

@end
