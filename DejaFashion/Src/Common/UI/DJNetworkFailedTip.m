//
//  DJNetworkFailedTip.m
//  DejaFashion
//
//  Created by DanyChen on 3/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import "DJNetworkFailedTip.h"
#import "UITips.h"

@implementation DJNetworkFailedTip

+ (void)showSlideDown:(float)originY insideParentView:(UIView *)parentView {
    [UITips showSlideDownTip:MOLocalizedString(@"No Internet Connection", @"") icon:nil duration:2 offsetY:originY insideParentView:parentView];
}



+(void)showToast:(UIView *)parentView {
    [MBProgressHUD showHUDAddedTo:parentView text:MOLocalizedString(@"NETWORK UNAVAILABLE", @"") animated:YES];
}

@end
