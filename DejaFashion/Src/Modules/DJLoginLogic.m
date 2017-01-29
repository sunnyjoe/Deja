//
//  DJLoginLogic.m
//
//
//  Created by DanyChen on 16/9/15.
//
//

#import "DJLoginLogic.h"
#import "DJNetTaskHandler.h"
#import "DJSignInAlertView.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "DJUserFeedbackLogic.h"
#import "DejaFashion-Swift.h"

@interface DJLoginLogic() <MONetTaskDelegate>

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, strong) LoginNetTask *loginNetTask;
@property (nonatomic, weak) id<ThirdPartyLoginDelegate> delegate;
@property (nonatomic, strong) BindAccountNetTask *bindNetTask;


@end

@implementation DJLoginLogic

static DJLoginLogic *sharedInstance;
+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

-(id)init
{
    NSAssert(!sharedInstance, @"This should be a singleton class.");
    self = [super init];
    if(self)
    {
        [[MONetTaskQueue instance] addTaskDelegate:self uri:[LogoutNetTask uri]];
        NSArray *notificationNames = [self notificationNames];
        for(NSString *notificationName in notificationNames){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:notificationName object:nil];
        }
    }
    return self;
}

-(void)addDelegate:(id<ThirdPartyLoginDelegate>)delegate {
    self.delegate = delegate;
}

-(void)setContainerView:(UIView *)parentView
{
    self.parentView = parentView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(NSArray *)notificationNames
{
    return [NSArray arrayWithObjects:kDJNetEventSignatureDidExpire,nil];
}

-(void)onReceiveNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didReceiveNotification:notification];
    });
}

-(void)didReceiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:kDJNetEventSignatureDidExpire]) {
        [[WardrobeSyncLogic sharedInstance] clearUserData];
        [DJLoginLogic clearUserData];
        [AccountDataContainer sharedInstance].userID = nil;
        [AccountDataContainer sharedInstance].signature = nil;
        [AccountDataContainer sharedInstance].userName = nil;
        [AccountDataContainer sharedInstance].avatar = nil;
        [AccountDataContainer sharedInstance].cartId = nil;
        [[MONetTaskQueue instance] addTask:[RegisterNetTask new]];
    }
}

+ (void)clearUserData {
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    
    //    [[DJStatisticsLogic instance] clearDataCache];
}

- (void)netTaskDidEnd:(MONetTask *)task
{
    if (self.loginNetTask == task) {
        if (!sharedWebView.superview) {
            AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate resetWebView];
        }
    }
    
    if ([task isMemberOfClass:[LogoutNetTask class]]) {
        if (!sharedWebView.superview) {
            AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate resetWebView];
        }
        [DJLoginLogic clearUserData];
    }
    
    if (self.bindNetTask == task) {
        [MBProgressHUD hideHUDForView:self.parentView animated:YES];
        [self.delegate thirdPartyBindDidSuccess];
    }
}


- (void)netTaskDidFail:(MONetTask *)task
{
    if (self.loginNetTask == task) {
        [MBProgressHUD hideHUDForView:self.parentView animated:YES];
    }
    
    if (self.loginNetTask == task) {
        [MBProgressHUD hideHUDForView:self.parentView animated:YES];
        [self.delegate thirdPartyLoginError];
    }
    
    if (self.bindNetTask == task) {
        [MBProgressHUD hideHUDForView:self.parentView animated:YES];
        [self.delegate thirdPartyBindDidError];
    }
}


-(void)facebookLoginWithSource
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    login.loginBehavior = FBSDKLoginBehaviorBrowser;
    [login
     logInWithReadPermissions: @[ @"public_profile", @"email", @"user_friends" ]
     fromViewController:self.parentView.viewController
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             [self.delegate thirdPartyLoginError];
         } else if (result.isCancelled) {
             [self.delegate thirdPartyLoginDidCanceled];
         } else {
             [self loginViaFacebook:result.token];
         }
     }];
}

-(void)bindFacebook {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    login.loginBehavior = FBSDKLoginBehaviorBrowser;
    [login
     logInWithReadPermissions: @[ @"public_profile", @"email", @"user_friends" ]
     fromViewController:self.parentView.viewController
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             [self.delegate thirdPartyBindDidError];
         } else if (result.isCancelled) {
             [self.delegate thirdPartyBindDidCanceled];
         } else {
             //bind nettask
             [self bindFacebook:result.token];
         }
     }];
}

-(void)loginWithTwitter {
    //    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
    //        if (session) {
    //            NSLog(@"signed in as %@", [session userName]);
    //        } else {
    //            NSLog(@"error: %@", [error localizedDescription]);
    //        }
    //    }];
}

-(void)loginViaFacebook: (FBSDKAccessToken *)token {
    if ([FBSDKAccessToken currentAccessToken]) {
        self.loginNetTask = [LoginNetTask new];
        FacebookInfo *info = [FacebookInfo new];
        info.token = [FBSDKAccessToken currentAccessToken].tokenString;
        self.loginNetTask.facebookInfo = info;
        [[MONetTaskQueue instance] addTaskDelegate:self uri:[LoginNetTask uri]];
        [[MONetTaskQueue instance] addTask:self.loginNetTask];
    }
}

-(void)bindFacebook: (FBSDKAccessToken *)token {
    if ([FBSDKAccessToken currentAccessToken]) {
        self.bindNetTask = [BindAccountNetTask new];
        FacebookInfo *info = [FacebookInfo new];
        info.token = [FBSDKAccessToken currentAccessToken].tokenString;
        self.bindNetTask.facebookInfo = info;
        [[MONetTaskQueue instance] addTaskDelegate:self uri:[self.bindNetTask uri]];
        [[MONetTaskQueue instance] addTask:self.bindNetTask];
    }
}


@end
