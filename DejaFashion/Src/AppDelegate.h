//
//  AppDelegate.h
//  DejaFashion
//
//  Created by Kevin Lin on 5/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <WebKit/WebKit.h>

WKWebView *sharedWebView;
BOOL sharedWebviewFinishloading;
BOOL needRefreshOutfits;

#define kDJAppDidEnterBackground                   @"kDJAppDidEnterBackground"
#define kDJAppWillEnterForeground                   @"kDJAppWillEnterForeground"
#define kDJAppReceiveReddotInfos                    @"kDJAppReceiveReddotInfos"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setRootViewController;

- (void)registerForAPN: (NSString*) title withDesc: (NSString*) desc;
-(void)registerForAPN;

- (void)resetWebView;

@end

