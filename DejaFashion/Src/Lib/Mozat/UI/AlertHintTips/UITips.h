//
//  UITips.h
//  DejaFashion
//
//  Created by DanyChen on 14/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITips : NSObject

//+ (void)showSlideDownTip: (NSString *)text offsetY: (float)originY insideParentView: (UIView *)parentView;

+ (void)showTip:(NSString *)text icon:(UIImage *)img duration:(UInt8)second offsetY:(float)originY insideParentView:(UIView *)parentView;

+ (void)showTip:(NSString *)text duration:(UInt8)second offsetY:(float)originY insideParentView:(UIView *)parentView ;

+ (void)showSlideDownTip:(NSString *)text icon:(UIImage *)img duration:(UInt8)second offsetY:(float)originY insideParentView:(UIView *)parentView;

+ (void)showPromotionTips:(NSString *)text icon:(UIImage *)img offsetY:(float)originY insideParentView:(UIView *)parentView;

@end
