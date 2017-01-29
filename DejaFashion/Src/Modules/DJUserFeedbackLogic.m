//
//  DJUserFeedbackLogic.m
//  DejaFashion
//
//  Created by Sun lin on 16/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import "DJUserFeedbackLogic.h"
//#import <Intercom/Intercom.h>
#import "DejaFashion-Swift.h"

//#if APPSTORE
//#define INTERCOM 0
//
//#elif PRODUCT
//#define INTERCOM 0
//
//#elif TEST
//#define INTERCOM 0
//
//#endif
//
//#define INTERCOM_APP_ID @"my8dw4xj"
//#define INTERCOM_API_KEY @"ios_sdk-98c0cfbc9c1eaff85292aad69a550c2c2646cdc8"


@implementation DJUserFeedbackLogic

static DJUserFeedbackLogic *sharedInstance;

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

-(id) init
{
    NSAssert(!sharedInstance, @"This should be a singleton class.");
    self = [super init];
    if(self)
    {
    }
    return self;
}

- (void) start
{
    
//#if INTERCOM
//    [Intercom setApiKey:INTERCOM_API_KEY forAppId:INTERCOM_APP_ID];
//    [Intercom setPreviewPosition:ICMPreviewPositionBottomRight];
//    [Intercom setPreviewPaddingWithX:20 y:15];
//    [Intercom setMessagesHidden:NO];
//    [Intercom setNeedsStatusBarAppearanceUpdate];
//#endif
}

- (void) registerUser
{
//#if INTERCOM
//    NSString *userID = [AccountDataContainer sharedInstance].userID;
//    NSString *email = [AccountDataContainer sharedInstance].email;
//    NSString *name = [AccountDataContainer sharedInstance].userName;
//    NSString *gender = [AccountDataContainer sharedInstance].gender;
//    
////    [Intercom registerUserWithUserId:@"&lt;#123456#&gt;"];
//    if (userID.length && name.length)
//    {
//        // We're logged in, we can register the user with Intercom
//    
//        if (email.length) {
//            [Intercom registerUserWithUserId:userID email:email];
//        }
//        else{
//            [Intercom registerUserWithUserId:userID];
//        }
//        
//        [Intercom updateUserWithAttributes:@{@"name" : name ,
//                                             @"gender": gender? gender : @"",
//                                             }];
//    }
//    else
//    {
//        // Since we aren't logged in, we are an unidentified user. Lets register.
//        [Intercom registerUnidentifiedUser];
//    }
//    
//#endif
}

- (void) unRegisterUser
{
//#if INTERCOM
//    // This reset's Intercom's cache of your user's identity and wipes the slate clean.
//    [Intercom reset];
//    // Now that you have logged your user out and reset, you can register a new
//    // unidentified user in their place.
//    [Intercom registerUnidentifiedUser];
//#endif
}

-(void) showConversationList
{
    
//#if INTERCOM
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [Intercom presentConversationList];
//    });
//#endif
}

-(void)showConversation
{
//#if INTERCOM
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [Intercom presentMessageComposer];
//    });
//#endif
}

-(void) setApnsToken:(NSData *)token
{
    
//#if INTERCOM
//    [Intercom setDeviceToken:token];
//#endif
}

-(void)addLogEvent:(NSString *)eventName{
    
//#if INTERCOM
//    [Intercom logEventWithName:eventName];
//#endif
}

-(void) handleNewMessage:(NSDictionary *)userInfo
{
    
//    NSString *appID = [userInfo objectForKey:@"app_id"];
////    if ([appID isEqualToString:INTERCOM_APP_ID]) {
//    
//        NSDictionary *aps = [userInfo objectForKey:@"aps"];
//        NSString *alert = [aps objectForKey:@"alert"];
//        
//        [DJAlertView alertViewWithTitle:alert message:userInfo.description
//                      cancelButtonTitle:MOLocalizedString(@"Dismiss", @"") otherButtonTitles:[NSArray arrayWithObject:MOLocalizedString(@"OK", @"")] onDismiss:^(int buttonIndex) {
//                          
//                      } onCancel:^{
//                      }];
////    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:DJNotifyIntercomNewMessage object:nil];
}
@end
