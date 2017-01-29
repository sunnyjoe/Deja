//
//  DJWebViewController.h
//  DejaFashion
//
//  Created by Sun lin on 10/4/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

@import TOWebViewController;
#import "DJBasicViewController.h"
#import <WebKit/WebKit.h>

#define kNotificationMissionOutfitCreated "kNotificationMissionOutfitCreated"


@interface DJWebViewController : DJBasicViewController

@property(nonatomic, retain)  WKWebView *webView;

@property(nonatomic, strong) UIBarButtonItem *backBarButton;
@property(nonatomic, strong) UIBarButtonItem *closeBarButton;


- (instancetype)initWithURLString:(NSString *)urlString;
- (BOOL)handleWebViewActionRequest:(NSURLRequest *)request;
- (void)handleUserTraceLog:(NSString *)eventId;

@property(nonatomic, strong) NSURL *url;

// if from push, don't use the shared webview
@property(nonatomic, assign) BOOL useSingleWebview;

//@{@"mission_id" : @"", @"mission_outfit_id" : @"", @"mission_desc" : @"", @"user_name" : @""}
@property(nonatomic, strong) NSDictionary *missionInfo;

@end
