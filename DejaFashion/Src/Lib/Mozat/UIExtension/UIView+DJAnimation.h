//
//  UIView+DJAnimation.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 5/10/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(DJAnimation)

-(void)appear:(float)beginAlpha delay:(float)delay durationtime:(float)duration completion:(void (^)())completion;
-(void)moveFrom:(CGPoint)fromPoint to:(CGPoint)toPoint time:(float)duration completion:(void (^)())completion;
- (void)showupFrom:(CGRect)fromRect to:(CGRect)toRect time:(float)duration completion:(void (^)())completion;

- (void)bouceShow:(CGRect)fullRect bouceScale:(float)scale showTime:(float)showTime bouceBackTime:(float)bouceTime startWidth:(float) startWidth alpha:(BOOL)hasAlpha completion:(void (^)())completion;
- (void)scaleShowAnimation:(CGRect)fullRect startWidth:(float)startWidth time:(float)duration alpha:(BOOL)hasAlpha completion:(void (^)())completion;
- (void)bouceExit:(CGRect)startRect bouceScale:(float)scale showTime:(float)showTime bouceBackTime:(float)bouceTime completion:(void (^)())completion;
 
- (void)rotateView:(float)angle scale:(float)scale time:(float)duration completion:(void (^)())completion;
@end
