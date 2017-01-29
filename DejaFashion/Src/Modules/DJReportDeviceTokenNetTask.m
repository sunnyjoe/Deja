//
//  DJReportDeviceTokenNetTask.m
//  DejaFashion
//
//  Created by Sun lin on 9/3/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJReportDeviceTokenNetTask.h"

@implementation DJReportDeviceTokenNetTask
+ (NSString *)uri
{
    return @"apis_bm/account/device_token/v4";
}

- (DJHTTPNetTaskMethod)method
{
    return DJHTTPNetTaskPost;
}

- (NSString *)uri
{
    return [self.class uri];
}

- (NSDictionary *)query
{
    
    NSString *dToken = self.deviceToken;//[[[NSString
    
    return @{ @"device_token": dToken};
}

- (void)didResponseJSON:(NSDictionary *)response
{
}

@end
