//
//  WKFRadarView.m
//  RadarDemo
//
//  Created by apple on 16/1/13.
//  Copyright © 2016年 吴凯锋 QQ:24272779. All rights reserved.
//

#import "WKFRadarView.h"
@interface WKFRadarView()
{
}

@property (nonatomic,weak)CALayer *animationLayer;

@end

@implementation WKFRadarView
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [[UIColor clearColor]setFill];
    UIRectFill(rect);
    NSInteger pulsingCount = 3;
    double animationDuration = 2;
    
    [self.animationLayer removeFromSuperlayer];
    CALayer * animationLayer = [[CALayer alloc]init];
    self.animationLayer = animationLayer;
    
    for (int i = 0; i < pulsingCount; i++) {
        CALayer * pulsingLayer = [[CALayer alloc]init];
        pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        pulsingLayer.backgroundColor = [UIColor colorFromHexString:@"f81f34"].CGColor;
        pulsingLayer.borderColor = [UIColor colorFromHexString:@"f81f34"].CGColor;
        pulsingLayer.borderWidth = 1.0;
        pulsingLayer.cornerRadius = rect.size.height/2;
        
        CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CAAnimationGroup * animationGroup = [[CAAnimationGroup alloc]init];
        animationGroup.fillMode = kCAFillModeBoth;
        animationGroup.beginTime = CACurrentMediaTime() + (double)i * animationDuration/(double)pulsingCount;
        animationGroup.duration = animationDuration;        animationGroup.repeatCount = HUGE_VAL;
        animationGroup.timingFunction = defaultCurve;
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.autoreverses = NO;
        scaleAnimation.fromValue = [NSNumber numberWithDouble:0.2];
        scaleAnimation.toValue = [NSNumber numberWithDouble:1.0];
        
        CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[[NSNumber numberWithDouble:1.0],[NSNumber numberWithDouble:0.5],[NSNumber numberWithDouble:0.3],[NSNumber numberWithDouble:0.0]];
        opacityAnimation.keyTimes = @[[NSNumber numberWithDouble:0.0],[NSNumber numberWithDouble:0.25],[NSNumber numberWithDouble:0.5],[NSNumber numberWithDouble:1.0]];
        animationGroup.animations = @[scaleAnimation,opacityAnimation];
        
        [pulsingLayer addAnimation:animationGroup forKey:@"pulsing"];
        [animationLayer addSublayer:pulsingLayer];
    }
    self.animationLayer.zPosition = -1;//重新加载时，使动画至底层
    [self.layer addSublayer:self.animationLayer];
    
    CALayer * thumbnailLayer = [[CALayer alloc]init];
    thumbnailLayer.backgroundColor = [UIColor whiteColor].CGColor;
    CGRect thumbnailRect = CGRectMake(0, 0, 46, 46);
    thumbnailRect.origin.x = (rect.size.width - thumbnailRect.size.width)/2.0;
    thumbnailRect.origin.y = (rect.size.height - thumbnailRect.size.height)/2.0;
    thumbnailLayer.frame = thumbnailRect;
    thumbnailLayer.cornerRadius = 23.0;
    thumbnailLayer.borderWidth = 1.0;
    thumbnailLayer.masksToBounds = YES;
    thumbnailLayer.borderColor = [UIColor whiteColor].CGColor;
}
@end
