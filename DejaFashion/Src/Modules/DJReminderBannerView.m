//
//  DJReminderBannerView.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 4/8/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJReminderBannerView.h"

@interface DJReminderBannerView ()
@property (strong, nonatomic) UILabel *countView;
@end

@implementation DJReminderBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.userInteractionEnabled = NO;
        [self buildUI];
    }
    return self;
}

- (void)buildUI{
    self.countView = [[UILabel alloc] initWithFrame:self.bounds];
    self.countView.textColor = [UIColor whiteColor];
    self.countView.font = [DJFont contentItalicFontOfSize:14];
    self.countView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.countView.textAlignment = NSTextAlignmentCenter;
    self.countView.userInteractionEnabled = NO;
    [self addSubview:self.countView];
}

-(void)setLabelStr:(NSString *)labelStr{
    self.countView.text = labelStr;
}

-(void)bannerAnimationDownUp{
    self.alpha = 1;
    float OY = self.frame.size.height;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, OY);
    } completion:^(BOOL completion){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL completion){self.alpha = 0;}];
        });
    }];
}

-(void)bannerAnimationInOut{
    self.alpha = 0;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0;
        } completion:nil];
    });
}
@end
