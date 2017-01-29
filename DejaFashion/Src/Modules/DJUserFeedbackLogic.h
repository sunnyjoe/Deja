//
//  DJUserFeedbackLogic.h
//  DejaFashion
//
//  Created by Sun lin on 16/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJUserFeedbackLogic : NSObject

+ (instancetype) instance;

- (void) start;

- (void) registerUser;

- (void) unRegisterUser;


-(void) showConversationList;

-(void)showConversation;

-(void) setApnsToken:(NSData *)token;

-(void)addLogEvent:(NSString *)eventName;

@end
