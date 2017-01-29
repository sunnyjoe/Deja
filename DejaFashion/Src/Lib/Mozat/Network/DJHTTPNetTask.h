//
//  DJHTTPNetTask.h
//  DejaFashion
//
//  Created by Kevin Lin on 11/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "MONetTask.h"

typedef enum {
    DJHTTPNetTaskGet,
    DJHTTPNetTaskPost
} DJHTTPNetTaskMethod;

typedef enum {
    DJHTTPNetTaskRequestQueryString,
    DJHTTPNetTaskRequestJSON
} DJHTTPRequestFormat;

@interface DJHTTPNetTask : MONetTask

- (NSURL *)baseURL;
- (DJHTTPRequestFormat)requestFormat;
- (DJHTTPNetTaskMethod)method;
- (NSDictionary *)query;
- (NSDictionary *)files;
- (void)didResponseJSON:(NSDictionary *)response;

@end
