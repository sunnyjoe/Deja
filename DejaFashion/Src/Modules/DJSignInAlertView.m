//
//  DJSignInAlertView.m
//  DejaFashion
//
//  Created by Kevin Lin on 15/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJSignInAlertView.h"
#import "DJLoginLogic.h"

@interface DJSignInAlertView ()<DJAlertViewDelegate>

@property (nonatomic, weak) id<DJSignInAlertViewDelegate> userDelegate;

@end

@implementation DJSignInAlertView

+ (void)alertSignInWithMessage:(NSString *)message loginSource:(NSString *)source delegate:(id<DJSignInAlertViewDelegate>)delegate
{
    DJSignInAlertView *alertView = [[DJSignInAlertView alloc] initWithTitle:@""
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:MOLocalizedString(@"Cancel", @"")
                                                          otherButtonTitles:MOLocalizedString(@"Sign in", @""), nil];
    alertView.delegate = alertView;
    alertView.userDelegate = delegate;
    [alertView show];
}


- (void)alertView:(DJAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
//        [[DJLoginLogic instance] facebookLoginWithSource];
        DJSignInAlertView *view = (DJSignInAlertView *)alertView;
        [view.userDelegate signInAlertViewDidClickLogin];
    }
}

@end
