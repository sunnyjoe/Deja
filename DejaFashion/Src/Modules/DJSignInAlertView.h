//
//  DJSignInAlertView.h
//  DejaFashion
//
//  Created by Kevin Lin on 15/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DJSignInAlertViewDelegate <NSObject>

- (void)signInAlertViewDidClickLogin;

@end

@interface DJSignInAlertView : DJAlertView

+ (void)alertSignInWithMessage:(NSString *)message loginSource:(NSString *)source delegate:(id<DJSignInAlertViewDelegate>)delegate;

@end
