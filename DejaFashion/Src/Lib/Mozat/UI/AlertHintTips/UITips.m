//
//  UITips.m
//  DejaFashion
//
//  Created by DanyChen on 14/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "UITips.h"
#import "DJWarningBanner.h"

@implementation UITips

+ (void)showTip:(NSString *)text icon:(UIImage *)img duration:(UInt8)second offsetY:(float)originY insideParentView:(UIView *)parentView  {
    DJWarningBanner *warningBanner = [DJWarningBanner new];
    warningBanner.frame =CGRectMake(0, originY, [UIScreen mainScreen].bounds.size.width, 35);
    [warningBanner setContent:text];
    [warningBanner setIcon:img];
    warningBanner.alpha = 0;
    warningBanner.contentMode = UIViewContentModeLeft;
    [parentView addSubview:warningBanner];
    __weak DJWarningBanner *weakBanner = warningBanner;
    [UIView animateWithDuration:0.45 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakBanner.alpha = 1;
    } completion:^(BOOL completion){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                weakBanner.alpha = 0;
            } completion:^(BOOL completion){
                weakBanner.hidden = YES;
            }];
        });
    }];
}


+ (void)showTip:(NSString *)text duration:(UInt8)second offsetY:(float)originY insideParentView:(UIView *)parentView  {
    [self showTip:text icon:nil duration:second offsetY:originY insideParentView:parentView];
}

+ (void)showSlideDownTip:(NSString *)text icon:(UIImage *)img duration:(UInt8)second offsetY:(float)originY insideParentView:(UIView *)parentView{
    DJWarningBanner *warningBanner = [DJWarningBanner new];
    warningBanner.frame = CGRectMake(0, -38 + originY, [UIScreen mainScreen].bounds.size.width, 38);
    [warningBanner setContent:text];
    [warningBanner setIcon:img];
    [parentView addSubview:warningBanner];
    __weak DJWarningBanner *weakBanner = warningBanner;
    [UIView animateWithDuration:0.45 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakBanner.frame = CGRectMake(0, originY, [UIScreen mainScreen].bounds.size.width, 38);
    } completion:^(BOOL completion){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                weakBanner.frame = CGRectMake(0, -38 + originY, [UIScreen mainScreen].bounds.size.width, 38);
            } completion:^(BOOL completion){
                weakBanner.hidden = YES;
            }];
        });
    }];
}



+ (void)showPromotionTips:(NSString *)text icon:(UIImage *)img offsetY:(float)originY insideParentView:(UIView *)parentView{
    DJWarningBanner *warningBanner = [DJWarningBanner new];
    warningBanner.frame = CGRectMake(0, originY, [UIScreen mainScreen].bounds.size.width, 38);
    warningBanner.backgroundColor = [UIColor colorFromHexString:@"f81f34"];
    [warningBanner setContent:text];
    [warningBanner setIcon:img];
    warningBanner.contentMode = UIViewContentModeLeft;
    [parentView addSubview:warningBanner];
//    __weak DJWarningBanner *weakBanner = warningBanner;

//    [UIView animateWithDuration:0.45 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        weakBanner.frame = CGRectMake(0, originY, [UIScreen mainScreen].bounds.size.width, 38);
//    } completion:^(BOOL completion){
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                weakBanner.frame = CGRectMake(0, -38 + originY, [UIScreen mainScreen].bounds.size.width, 38);
//            } completion:^(BOOL completion){
//                weakBanner.hidden = YES;
//            }];
//        });
//    }];
}


@end
