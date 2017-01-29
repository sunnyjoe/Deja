//
//  AppDelegate.m
//  DejaFashion
//
//  Created by Kevin Lin on 5/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "AppDelegate.h"
#import "CocoaLumberjack.h"
#import "DJNetTaskHandler.h"
#import "MONetTaskQueue.h"
#import "DJConfigDataContainer.h"
#import <HockeySDK/HockeySDK.h>
#import <FBSDKCoreKit/FBSDKAppLinkUtility.h>
#import "DJConfigDataContainer.h"
#import "MOUserAgent.h"
#import "DJNetworkTypeUtil.h"
#import "DJAppCall.h"
#import "DJReportDeviceTokenNetTask.h"
#import "DejaFashion-Swift.h"
#import "DJJSPatchHandler.h"
#import "PerforMadTrackingCode.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import "DJUserFeedbackLogic.h"
#import "DJHookMethodTool.h"
#import <AdSupport/AdSupport.h>
#import <AppsFlyer/AppsFlyer.h>
#import "WXApi.h"

@import KLCPopup;
@import GoogleMaps;

#define shared_webview_reset_interval 24 * 3600 * 1000
#define system_config_fetch_interval 24 * 3600 * 1000


@interface AppDelegate ()

@property (nonatomic, assign) NSTimeInterval enterForegroundTime;
@property (nonatomic, retain) NSDictionary *triggeringPushNotif;
@property (nonatomic, strong) NSTimer *redDotTimer;
@property (nonatomic, copy) NSURL *urlToOpen;
@property (nonatomic, copy) NSString *sourceApplicationToOpenUrl;

@property (nonatomic, assign) NSTimeInterval lastGetConfigTime;
@property (nonatomic, assign) NSTimeInterval lastTimeInitWebview;

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
//@property (nonatomic, assign) NSTimer bgTask;

@property (nonatomic, weak) KLCPopup *popup;

@end

@implementation AppDelegate{
    UInt64 time1;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initialConfig];
    time1 = [NSDate currentTimeMillis];
    [[DJUserFeedbackLogic instance] start];
    [[DJUserFeedbackLogic instance] registerUser];
    [[DJJSPatchHandler instance] useJSPatch];
    [[DJStatisticsLogic instance] setup];
    [GMSServices provideAPIKey:kDJGoogleMapAppKey];
    [WXApi registerApp:kDJWechatAppKey];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self resetUA];
    
    [self initHttpAndSendServerConfigNetTask];
    [self splashViewDidFinish:launchOptions];
    
    [self.window makeKeyAndVisible];
  
    if([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]){
        [[LocationManager sharedInstance] startSignificiantMonitor];
    }
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDJAppDidEnterBackground object:nil];
    
    [[LocationManager sharedInstance] stopAccurateMonitor];
}


-(void)initialConfig
{
    
    //    if ([ConfigDataContainer sharedInstance].firstTimeLaunch)
    //    {
    //        [DJConfigDataContainer instance].newInstallTemp = YES;
    //    }
    
    if ([ConfigDataContainer sharedInstance].firstTimeLaunch) {
        [ConfigDataContainer sharedInstance].firstTimeLaunch = NO;
        [[DJStatisticsLogic instance] addTraceLog:[DJStatisticsKeys system_new_launch]];
    }
    
    if (![ConfigDataContainer sharedInstance].firstTimeInstallAppVersion) {
        [ConfigDataContainer sharedInstance].firstTimeInstallAppVersion = [MOUserAgent instance].fullVersionString;
    }
}

- (void)resetWebView {
    [sharedWebView stopLoading];
    sharedWebView = nil;
    self.lastTimeInitWebview = [NSDate currentTimeMillis];
    sharedWebviewFinishloading = false;
    needRefreshOutfits = false;
}

- (void)initHttpAndSendServerConfigNetTask {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:50 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [MONetTaskQueue instance].delegate = [DJNetTaskHandler instance];
    //    DJGetConfigNetTask *task = [DJGetConfigNetTask new];
    //    [[MONetTaskQueue instance] addTask:task];
    NSString *uid = [AccountDataContainer sharedInstance].userID;
    
    NSString* currentVersion = [AppConfig currentVersion];
    if (![[ConfigDataContainer sharedInstance].lastAppLaunchVersion isEqualToString: currentVersion]) {
        [ConfigDataContainer sharedInstance].lastAppLaunchVersion = currentVersion;
        [[WardrobeSyncLogic sharedInstance] clearUserData];
    }
    
    if (!uid.length)
    {
        RegisterNetTask *task = [RegisterNetTask new];
        [[MONetTaskQueue instance] addTask:task];
    }else {
        [self resetWebView];
        if ([[AccountDataContainer sharedInstance] isAnonymous]) {
            // old version
            if ([AccountDataContainer sharedInstance].signature.length) {
                [AccountDataContainer sharedInstance].signature = @"";
            }
        }
        
        [[WardrobeSyncLogic sharedInstance] triggerSync];
    }
    [DJLoginLogic instance];
    [self sendConfigNetTaskIfNeeded];
}

- (void)splashViewDidFinish:(NSDictionary *)launchOptions {
    
    [self launchSafely:launchOptions];
    if (self.urlToOpen) {
        [DJAppCall handleOpenURL:self.urlToOpen sourceApplication:self.sourceApplicationToOpenUrl];
        self.urlToOpen = nil;
        self.sourceApplicationToOpenUrl = nil;
    }
}

- (void)launchSafely:(NSDictionary *)launchOptions {
    
    
    [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url,NSError *error){
        if(url.absoluteString.length > 0)
        {
            [self application:[UIApplication sharedApplication] openURL:url sourceApplication:@"FB" annotation:[NSDictionary new]];
        }
    }];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kDJHockeyappID];
    [[BITHockeyManager sharedHockeyManager] setDisableUpdateManager:YES];
    
    [BITHockeyManager sharedHockeyManager].crashManager.crashManagerStatus = BITCrashManagerStatusAutoSend;
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    
    [self setRootViewController];
    
    self.enterForegroundTime = [[NSDate date] timeIntervalSince1970];
    
    [DJHookMethodTool hookStatistics];
    
    NSDictionary *pushNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    self.triggeringPushNotif = pushNotif;
    
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication]
                             didFinishLaunchingWithOptions:launchOptions];
    [self addPerforMadSdk];
    
    [DJSpotlightSearchSupport addIndexes];
}

- (void)resetUA {
    //get the original user-agent of webview
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    //add my info to the new agent
    NSString *newAgent = [oldAgent stringByAppendingString:[NSString stringWithFormat:@" Deja%@ deviceId/%@", [MOUserAgent instance].fullVersionString, [MOUserAgent instance].deviceID]];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    //regist the new agent
}

- (void)addPerforMadSdk {
    [PerforMadTrackingCode setDebugMode:NO];
    [PerforMadTrackingCode setCoversionId:@"194fb10c7dcc5595"];
    [PerforMadTrackingCode setMarketChannel:@"AppStore"];
    [PerforMadTrackingCode dispatchPolicy:POLICY_REAL];
}

- (void)setRootViewController
{
    UInt64 time2 = [NSDate currentTimeMillis] - time1;
    [DJLog info:DJ_UI content:@"splashpage during = %d", time2];
    //    if (![[DJConfigDataContainer instance].tutorialVersion isEqualToString:[DJNewFeatureIntroductionViewController versionOfNew]]){
    //        [DJConfigDataContainer instance].tutorialVersion = [DJNewFeatureIntroductionViewController versionOfNew];
    //        [DJNewFeatureIntroductionViewController startExplore];
    //    }else {
    self.window.rootViewController = [MainTabViewController sharedInstance];
    //    }
}

- (void)tutorialViewControllerDidFinish
{
    [self setRootViewController];
}

//-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //    [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation
     ];
    BOOL actionResolved = [DJAppCall handleOpenURL:url sourceApplication:sourceApplication];
    if (!actionResolved) {
        self.urlToOpen = url;
        self.sourceApplicationToOpenUrl = sourceApplication;
    }
    return actionResolved;
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler
{
    if([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb])
    {
        NSURL *webUrl = userActivity.webpageURL;
        //        [DJLog error:DJ_SYSTEM content:webUrl.absoluteString];
        //        [DJLog error:DJ_SYSTEM content:webUrl.query];
        if(webUrl)
        {
            NSRange range = [webUrl.absoluteString rangeOfString:@"schema="];
            if(range.length)
            {
                NSString *urlAbsoluteString = [webUrl.absoluteString substringFromIndex:range.location + range.length];
                NSURL *url = [NSURL URLWithString:urlAbsoluteString];
                BOOL actionResolved = [DJAppCall handleOpenURL: url sourceApplication:nil];
                if (!actionResolved) {
                    self.urlToOpen = url;
                    self.sourceApplicationToOpenUrl = nil;
                }
            }
        }
    }
    else if([userActivity.activityType isEqualToString:CSSearchableItemActionType])
    {
        NSURL *url = [NSURL URLWithString:@"dejafashion://fittingroom"];
        BOOL actionResolved = [DJAppCall handleOpenURL:url sourceApplication:nil];
        if (!actionResolved) {
            self.urlToOpen = url;
            self.sourceApplicationToOpenUrl = nil;
        }
    }
    else
    {
        return NO;
    }
    return YES;
}

-(void)applicationWillTerminate:(UIApplication *)application{
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDJAppWillEnterForeground object:nil];
    
    [self sendConfigNetTaskIfNeeded];
    
    [self resetWebviewIfNeeded];
}

- (void) sendConfigNetTaskIfNeeded {
    UInt64 currentMills = [NSDate currentTimeMillis];
    if (currentMills - self.lastGetConfigTime > system_config_fetch_interval) {
        GetSystemConfigNetTask *task = [GetSystemConfigNetTask new];
        [[MONetTaskQueue instance] addTask:task];
        self.lastGetConfigTime = currentMills;
    }
}

- (void) resetWebviewIfNeeded {
    UInt64 currentMills = [NSDate currentTimeMillis];
    if (currentMills - self.lastTimeInitWebview > shared_webview_reset_interval) {
        if (!sharedWebView.superview) {
            [self resetWebView];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.enterForegroundTime = [[NSDate date] timeIntervalSince1970];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kDJAppDidEnterBackground object:nil];
    
    // start pushing messages
    //    self.triggeringPushNotif = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"type",  @"http://www.163.com", @"url",nil];
    //    NSString *temp = [NSString urlEncode:@"http://www.163.com"];
    //    self.triggeringPushNotif = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"type",  [NSString stringWithFormat:@"dejafashion://webview?url=%@", temp], @"url",nil];
    //         self.triggeringPushNotif = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"type",  @"dejafashion://friendList", @"url",nil];
    
    if (self.triggeringPushNotif)
    {
        [DJLog error:DJ_NETWORK content:self.triggeringPushNotif.description];
        NSNumber *numType = [self.triggeringPushNotif objectForKey:@"type"];
        if (numType.intValue == 0)
        {
        }
        else if(numType.intValue == 1 || numType.intValue == 2)
        {
            NSString *url = [self.triggeringPushNotif objectForKey:@"url"];
            [DJAppCall handleOpenURL:[NSURL URLWithString:url] sourceApplication:@"deja"];
        }
        
        [[DJStatisticsLogic instance] addTraceLog:[DJStatisticsKeys system_click_notification]];
    }
    self.triggeringPushNotif = nil;
    [FBSDKAppEvents activateApp];
    [[DJStatisticsLogic instance] handleAfterAppBecomeActive];
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if (state == UIApplicationStateActive)
    {
        //        [[DJUserFeedbackLogic instance] handleNewMessage:userInfo];
        NSNumber *numType = [userInfo objectForKey:@"type"];
        if (numType.intValue == 0)
        {
        }
        else if(numType.intValue == 1)
        {
            NSString *url = [userInfo objectForKey:@"url"];
            if ([url isEqualToString:@"dejafashion://friendList"] || [url isEqualToString:@"dejafashion://messageList"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kDJAppReceiveReddotInfos" object:@{@"wardrobe_buddy": @1}];
                return ;
            }
            
            NSDictionary *aps = [userInfo objectForKey:@"aps"];
            NSString *alert = [aps objectForKey:@"alert"];
            
            [DJAlertView alertViewWithTitle:MOLocalizedString(@"New Message", @"") message:alert
                          cancelButtonTitle:MOLocalizedString(@"Dismiss", @"") otherButtonTitles:[NSArray arrayWithObject:MOLocalizedString(@"View", @"")] onDismiss:^(int buttonIndex) {
                              NSString *url = [userInfo objectForKey:@"url"];
                              [DJAppCall handleOpenURL:[NSURL URLWithString:url] sourceApplication:@"deja"];
                              
                          } onCancel:^{
                          }];
        }
    }
    else
    {
        self.triggeringPushNotif = userInfo;
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    if (!sharedWebView.superview) {
        [self resetWebView];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *uid = [AccountDataContainer sharedInstance].userID;
    
    NSString *pushToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    [AccountDataContainer sharedInstance].pushToken = pushToken;
    if (uid.length)
    {
        DJReportDeviceTokenNetTask *task = [DJReportDeviceTokenNetTask new];
        task.deviceToken = pushToken;
        [[MONetTaskQueue instance] addTask:task];
    }
    [[DJUserFeedbackLogic instance] setApnsToken:deviceToken];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (settings.types != UIUserNotificationTypeNone) {
            if (![DJConfigDataContainer instance].handledPushAccessPermission) {
                [DJConfigDataContainer instance].handledPushAccessPermission = YES;
                [[DJStatisticsLogic instance] addTraceLog:[DJStatisticsKeys system_click_allow_push]];
            }
        }
    });
    
}


int retryCount = 0;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (retryCount < 10) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            retryCount++;
        }
    });
}

-(void)registerForAPN
{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)registerForAPN: (NSString*) title withDesc: (NSString*) desc;
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            [ConfigDataContainer sharedInstance].pushPopupTipHasShown = true;
            return;
        }
        
        if ([ConfigDataContainer sharedInstance].pushPopupTipHasShown) {
            return;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 255, 255)];
        view.backgroundColor = [UIColor colorFromHexString:@"9bd097"];
        
        UIImage *icon = [UIImage imageNamed:@"GreenSuccessIcon"];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:icon];
        iconImageView.frame = CGRectMake(100, 25, 55, 55);
        [view addSubview:iconImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 255, 20)];
        label.text = title;
        [label textCentered];
        [label withFontHeleticaMedium:17];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 130, 255, 125)];
        blackView.backgroundColor = [UIColor colorFromHexString:@"262729"];
        
        [view addSubview:blackView];
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.5, 8, 200, 60)];
        descLabel.text = desc;
        descLabel.numberOfLines = 0;
        [descLabel withFontHeletica:14];
        descLabel.textColor = [UIColor whiteColor];
        [blackView addSubview:descLabel];
        
        DJButton *ignoreButton = [[DJButton alloc] initWithFrame:CGRectMake(27.5, 68, 95, 33)];
        [ignoreButton whiteTitleTransparentStyle];
        ignoreButton.layer.cornerRadius = 16.5;
        [ignoreButton setTitle:@"No,thanks" forState:UIControlStateNormal];
        [ignoreButton addTarget:self action:@selector(ignore) forControlEvents:UIControlEventTouchUpInside];
        
        DJButton *comfirmButton = [[DJButton alloc] initWithFrame:CGRectMake(137.5, 68, 95, 33)];
        [comfirmButton whiteTitleTransparentStyle];
        comfirmButton.layer.cornerRadius = 16.5;
        [comfirmButton setTitle:@"Notify me" forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        [blackView addSubview:ignoreButton];
        [blackView addSubview:comfirmButton];
        
        KLCPopup *popup = [KLCPopup popupWithContentView:view];
        self.popup = popup;
        popup.shouldDismissOnBackgroundTouch = YES;
        
        [popup show];
    }
}

- (void)ignore {
    [self.popup dismiss:YES];
}

- (void)confirm {
    [self.popup dismiss:YES];
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if (shortcutItem.type != nil) {
        NSURL *url = [NSURL URLWithString:shortcutItem.type];
        BOOL actionResolved = [DJAppCall handleOpenURL:url sourceApplication:nil];
        if (!actionResolved) {
            self.urlToOpen = url;
            self.sourceApplicationToOpenUrl = nil;
        }
    }
}




@end
