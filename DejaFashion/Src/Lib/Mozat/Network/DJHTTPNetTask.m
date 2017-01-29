//
//  DJHTTPNetTask.m
//  DejaFashion
//
//  Created by Kevin Lin on 11/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJHTTPNetTask.h"

@implementation DJHTTPNetTask

- (NSURL *)baseURL
{
    return nil;
}

- (DJHTTPRequestFormat)requestFormat
{
    return [self method] == DJHTTPNetTaskGet ? DJHTTPNetTaskRequestQueryString : DJHTTPNetTaskRequestJSON;
}

- (DJHTTPNetTaskMethod)method
{
    return DJHTTPNetTaskGet;
}

- (NSDictionary *)query
{
    return nil;
}

- (NSDictionary *)files
{
    return nil;
}

- (void)didResponse:(NSObject *)response
{
    [self didResponseJSON:(NSDictionary *)response];
}

- (void)didResponseJSON:(NSDictionary *)response
{
    
}

@end
