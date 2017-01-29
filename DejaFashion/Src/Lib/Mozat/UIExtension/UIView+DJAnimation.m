//
//  UIView+DJAnimation.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 5/10/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import "UIView+DJAnimation.h"

@implementation UIView (DJAnimation)

-(void)showupFrom:(CGRect)fromRect to:(CGRect)toRect time:(float)duration completion:(void (^)())completion{
    self.frame = fromRect;
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:duration
                          delay: 0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         weakSelf.frame = toRect;
                     }
                     completion:^(BOOL finished){
                         if (completion) {
                             completion();
                         }
                     }];
    
}

-(void)appear:(float)beginAlpha delay:(float)delay durationtime:(float)duration completion:(void (^)())completion{
    self.alpha = beginAlpha;
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:duration
                          delay: delay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         weakSelf.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         if (completion) {
                             completion();
                         }
                     }];
}

-(void)moveFrom:(CGPoint)fromPoint to:(CGPoint)toPoint time:(float)duration completion:(void (^)())completion{
    //  self.frame = CGRectMake(fromPoint.x, fromPoint.y, self.frame.size.width, self.frame.size.height);
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:duration
                          delay: 0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         weakSelf.frame = CGRectMake(toPoint.x, toPoint.y, weakSelf.frame.size.width, weakSelf.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         weakSelf.frame = CGRectMake(toPoint.x, toPoint.y, weakSelf.frame.size.width, weakSelf.frame.size.height);
                         
                         if (completion) {
                             completion();
                         }
                     }];
    
}

-(void)rotateView:(float)angle scale:(float)scale time:(float)duration completion:(void (^)())completion{
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:duration
                          delay: 0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         weakSelf.transform = CGAffineTransformRotate(weakSelf.transform, angle);
                         weakSelf.transform = CGAffineTransformScale(weakSelf.transform, scale, scale);
                     }
                     completion:^(BOOL finished){
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)bouceShow:(CGRect)fullRect bouceScale:(float)scale showTime:(float)showTime bouceBackTime:(float)bouceTime startWidth:(float) startWidth alpha:(BOOL)hasAlpha completion:(void (^)())completion{
    __weak UIView *weakSelf = self;
    CGRect scaledRect = CGRectMake(fullRect.origin.x + fullRect.size.width * (1 - scale) / 2, fullRect.origin.y + fullRect.size.height * (1 - scale) / 2, fullRect.size.width * scale, fullRect.size.height * scale);
    [self scaleShowAnimation:scaledRect startWidth:startWidth time:showTime alpha:hasAlpha completion:^(){
        [weakSelf scaleShowAnimation:fullRect startWidth:scaledRect.size.width time:bouceTime alpha:NO completion:completion];
    }];
}

- (void)bouceExit:(CGRect)startRect bouceScale:(float)scale showTime:(float)showTime bouceBackTime:(float)bouceTime completion:(void (^)())completion{
    __weak UIView *weakSelf = self;
    CGRect scaledRect = CGRectMake(startRect.origin.x + startRect.size.width * (1 - scale) / 2, startRect.origin.y + startRect.size.height * (1 - scale) / 2, startRect.size.width * scale, startRect.size.height * scale);
    [weakSelf scaleShowAnimation:scaledRect startWidth:startRect.size.width time:showTime alpha:NO completion:^(){
        [UIView animateWithDuration:bouceTime
                              delay: 0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             weakSelf.transform = CGAffineTransformMakeScale(0.01, 0.01);
                         }
                         completion:^(BOOL finished){
                             weakSelf.transform = CGAffineTransformIdentity;
                             
                             if (completion) {
                                 weakSelf.alpha = 0;
                                 weakSelf.frame = startRect;
                                 completion();
                             }
                         }];
    }];
}

- (void)scaleShowAnimation:(CGRect)fullRect startWidth:(float)startWidth time:(float)duration alpha:(BOOL)hasAlpha completion:(void (^)())completion{
    if (hasAlpha) {
        self.alpha = 0;
    }else{
        self.alpha = 1;
    }
    self.frame = fullRect;
    float scale = startWidth / fullRect.size.width;
    
    self.transform = CGAffineTransformMakeScale(scale, scale);
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:duration
                          delay: 0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (hasAlpha){
                             weakSelf.alpha = 1;
                         }
                         weakSelf.transform = CGAffineTransformMakeScale(1, 1);
                         weakSelf.hidden = false;
                     }
                     completion:^(BOOL finished){
                         weakSelf.transform = CGAffineTransformIdentity;
                         
                         if (completion) {
                             completion();
                         }
                     }];
}

@end
