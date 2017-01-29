//
//  DJNetTaskHandler.m
//  DejaFashion
//
//  Created by Kevin Lin on 11/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJNetTaskHandler.h"
#import "DJHTTPNetTask.h"
#import "AFNetworking.h"
#import "MONetTaskQueue.h"
#import "DJConfigDataContainer.h"
#import "MOUserAgent.h"
#import "DejaFashion-Swift.h"

static DJNetTaskHandler *sharedInstance;

@implementation DJNetTaskHandler
{
    AFHTTPSessionManager *httpQueryStringManager;
    AFHTTPSessionManager *httpJSONManager;
}

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init
{
    NSAssert(!sharedInstance, @"This should be a singleton class.");
    if (self = [super init]) {
        NSURL *baseURL = [NSURL URLWithString:DJServerBaseURL];
        httpQueryStringManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        httpJSONManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        
        httpJSONManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)netTaskQueue:(MONetTaskQueue *)netTaskQueue task:(MONetTask *)task taskId:(int)taskId
{
    NSAssert([task isKindOfClass:[DJHTTPNetTask class]], @"Should be subclass of DJHTTPNetTask");
    
    void (^success)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *response = responseObject;
        int ret = [response[@"ret"] intValue];
        if (ret != 0) {
            if (ret == 1001 && AccountDataContainer.sharedInstance.userID.length) { // Signature expired
                [[NSNotificationCenter defaultCenter] postNotificationName:kDJNetEventSignatureDidExpire object:nil];
                return;
            }
            NSError *error = [NSError errorWithDomain:kDJAPIErrorDomain code:ret userInfo:@{ @"msg": response[@"msg"] }];
            [DJLog error:DJ_NETWORK content:@"FAILED: %@, %@", task.response.URL.absoluteString, [error description]];
            [[MONetTaskQueue instance] didFailWithError:error taskId:taskId];
            [[DJStatisticsLogic instance] addTraceLog:kStatisticsID_http_error withParameter:@{ @"api" : task.response.URL.path, @"ret": @(ret)}];
        }
        else {
            [[MONetTaskQueue instance] didResponse:responseObject taskId:taskId];
        }
    };
    
    void (^failure)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        [DJLog error:DJ_NETWORK content:@"FAILED: %@, %@", task.response.URL.absoluteString, [error description]];
        [[MONetTaskQueue instance] didFailWithError:error taskId:taskId];
    };
    
    DJHTTPNetTask *httpTask = (DJHTTPNetTask *)task;
    NSString *url = [httpTask uri];
    
    // TODO NETWORK MAKE UID FLEXIABLE
    if (AccountDataContainer.sharedInstance.userID.length) {
        url = [NSString stringWithFormat:@"%@?uid=%@", [httpTask uri], AccountDataContainer.sharedInstance.userID];
        if (AccountDataContainer.sharedInstance.signature.length) {
            url = [NSString stringWithFormat:@"%@?uid=%@&sig=%@", [httpTask uri], AccountDataContainer.sharedInstance.userID, AccountDataContainer.sharedInstance.signature];
        }
    }
    
    AFHTTPSessionManager *httpManager = nil;
    if (httpTask.baseURL) {
        httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:httpTask.baseURL];
        if ([httpTask requestFormat] == DJHTTPNetTaskRequestJSON) {
            httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
    }
    else if ([httpTask requestFormat] == DJHTTPNetTaskRequestQueryString) {
        httpManager = httpQueryStringManager;
    }
    else if ([httpTask requestFormat] == DJHTTPNetTaskRequestJSON){
        httpManager = httpJSONManager;
    }
    else {
        NSAssert(NO, @"Invalid DJHTTPNetTaskRequestFormat");
    }
    
    [httpManager.requestSerializer setValue:[MOUserAgent instance].userAgent forHTTPHeaderField:@"x-dejafashion-ua"];
    
    if ([httpTask method] == DJHTTPNetTaskGet) {
        [httpManager GET:url parameters:[httpTask query] success:success failure:failure];
        [DJLog info:DJ_NETWORK content:@"GET: URL: %@/%@, REQ: %@", httpManager.baseURL, url, [httpTask query].description];
        httpTask.requestTimeInMills = [NSDate currentTimeMillis];
    }
    else if ([httpTask method] == DJHTTPNetTaskPost) {
        if (!httpTask.files.count) {
            [httpManager POST:url parameters:[httpTask query] success:success failure:failure];
            [DJLog info:DJ_NETWORK content:@"POST: URL: %@/%@, REQ: %@" , httpManager.baseURL, url, [httpTask query].description];
        }
        else {
            [httpManager POST:url parameters:[httpTask query] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                NSDictionary *files = [httpTask files];
                for (NSString *name in files.allKeys) {
                    [formData appendPartWithFileData:files[name] name:name fileName:name mimeType:@"image/png"];
                }
                [DJLog info:DJ_NETWORK content:@"POST: URL = %@/%@, REQ = %@， FILES = %@", httpManager.baseURL, url, [httpTask query].description, files.allKeys.description];
            } success:success failure:failure];
        }
        httpTask.requestTimeInMills = [NSDate currentTimeMillis];
    }
    else {
        NSAssert(NO, @"Invalid DJHTTPNetTaskMethod");
    }
}

@end
