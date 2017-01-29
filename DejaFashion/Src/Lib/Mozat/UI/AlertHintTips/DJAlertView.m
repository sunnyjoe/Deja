//
//  DJAlertView.m
//  DejaFashion
//
//  Created by Kevin Lin on 21/1/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJAlertView.h"

#define DJAlertViewPaddingV 35
#define DJAlertViewSpacingV 20
#define DJAlertViewBtnHeight 55

static UIWindow *alertViewWindow;

@implementation DJAlertView
{
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    UIButton *_cancelBtn;
    UIButton *_otherButton;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<DJAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSMutableArray *otherButtonTitlesArray = nil;
    if (otherButtonTitles) {
        va_list args;
        va_start(args, otherButtonTitles);
        otherButtonTitlesArray = [[NSMutableArray alloc] initWithObjects:otherButtonTitles, nil];
        id obj;
        while ((obj = va_arg(args, id)) != nil) {
            [otherButtonTitlesArray addObject:obj];
        }
        va_end(args);
    }
    return [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitlesArray:otherButtonTitlesArray];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<DJAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitlesArray:(NSArray *)otherButtonTitlesArray
{
    if (self = [super init]) {
        // TODO (kevin) Currently only two buttons are supported
        NSAssert(title || message, @"DJAlertView should have title and message, or only one of them");
        NSAssert(cancelButtonTitle || (otherButtonTitlesArray && otherButtonTitlesArray.count), @"DJAlertView should at least one button");
        
        if (!alertViewWindow) {
            alertViewWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            alertViewWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            alertViewWindow.windowLevel = UIWindowLevelAlert;
        }
        
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = delegate;
        
        float alertViewWidth = 310 * [UIScreen mainScreen].bounds.size.width / 375;
        if (alertViewWidth > 310) {
            alertViewWidth = 310;
        }
        
        if (message.length && !title.length) {
            title = message;
            message = nil;
        }
        
        if (title.length) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, alertViewWidth - 40, 0)];
            _titleLabel.font = [DJFont mediumHelveticaFontOfSize:18];
            _titleLabel.textColor = [UIColor colorFromHexString:@"414141"];
            _titleLabel.text = title;
            _titleLabel.numberOfLines = 0;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            [_titleLabel sizeToFit];
            [self addSubview:_titleLabel];
        }
        if (message.length) {
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, alertViewWidth - 40, 0)];
            _messageLabel.font = [DJFont contentFontOfSize:16];
            _messageLabel.textColor = [UIColor colorFromHexString:@"818181"];
            _messageLabel.text = message;
            _messageLabel.numberOfLines = 0;
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            [_messageLabel sizeToFit];
            [self addSubview:_messageLabel];
        }
        
        int btnIndex = 0;
        if (cancelButtonTitle.length) {
            _cancelBtn = [UIButton new];
            _cancelBtn.tag = btnIndex;
            _cancelBtn.titleLabel.font = [DJFont contentFontOfSize:17];
            [_cancelBtn addTarget:self action:@selector(btnDidTap:) forControlEvents:UIControlEventTouchUpInside];
            [_cancelBtn setTitleColor:[UIColor colorFromHexString:@"414141"] forState:UIControlStateNormal];
            [_cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [_cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"f6f6f6"]] forState:UIControlStateNormal];
            [_cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"ffffff"]] forState:UIControlStateHighlighted];
            [self addSubview:_cancelBtn];
            btnIndex++;
        }
        if (otherButtonTitlesArray && otherButtonTitlesArray.count) {
            NSString *otherButtonTitle = otherButtonTitlesArray[0];
            _otherButton = [UIButton new];
            _otherButton.tag = btnIndex;
            _otherButton.titleLabel.font = [DJFont contentFontOfSize:17];
            [_otherButton addTarget:self action:@selector(btnDidTap:) forControlEvents:UIControlEventTouchUpInside];
            [_otherButton setTitleColor:[UIColor colorFromHexString:@"ffffff"] forState:UIControlStateNormal];
            [_otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
            [_otherButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"262729"]] forState:UIControlStateNormal];
            [_otherButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"818181"]] forState:UIControlStateHighlighted];
            [self addSubview:_otherButton];
            btnIndex++;
        }
        
        float textHeight = _titleLabel.frame.size.height + _messageLabel.frame.size.height;
        float textContainerHeight = DJAlertViewPaddingV * 2 + textHeight;
        if (_titleLabel && _messageLabel) {
            textHeight += DJAlertViewSpacingV;
            textContainerHeight += DJAlertViewSpacingV;
        }
        if (textContainerHeight < 115) {
            textContainerHeight = 115;
        }
        float alertViewHeight = textContainerHeight + DJAlertViewBtnHeight;
        
        self.frame = CGRectMake((alertViewWindow.frame.size.width - alertViewWidth) / 2,
                                (alertViewWindow.frame.size.height - alertViewHeight) / 2,
                                alertViewWidth, alertViewHeight);
        
        float textY = (textContainerHeight - textHeight) / 2;
        if (_titleLabel) {
            CGRect frame = _titleLabel.frame;
            frame.origin = CGPointMake((alertViewWidth - frame.size.width) / 2, textY);
            _titleLabel.frame = frame;
            textY += frame.size.height + DJAlertViewSpacingV;
        }
        if (_messageLabel) {
            CGRect frame = _messageLabel.frame;
            frame.origin = CGPointMake((alertViewWidth - frame.size.width) / 2, textY);
            _messageLabel.frame = frame;
        }
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, alertViewHeight - DJAlertViewBtnHeight - 0.5,
                                                                         alertViewWidth, 0.5)];
        separatorView.backgroundColor = [UIColor colorFromHexString:@"e4e4e4"];
        [self addSubview:separatorView];
        
        float btnX = 0;
        float btnY = alertViewHeight - DJAlertViewBtnHeight;
        float btnWidth = alertViewWidth;
        if (_cancelBtn && _otherButton) {
            btnWidth /= 2;
        }
        
        if (_cancelBtn) {
            _cancelBtn.frame = CGRectMake(btnX, btnY, btnWidth, DJAlertViewBtnHeight);
            btnX += btnWidth;
        }
        if (_otherButton) {
            _otherButton.frame = CGRectMake(btnX, btnY, btnWidth, DJAlertViewBtnHeight);
        }
    }
    return self;
}


 
- (void)btnDidTap:(UIButton *)btn
{
    [self hide];
    NSInteger btnIndex = btn.tag;
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:btnIndex];
    }
}

- (void)show
{
    [alertViewWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [alertViewWindow addSubview:self];
    alertViewWindow.hidden = NO;
    alertViewWindow.alpha = 1;
    self.transform = CGAffineTransformMakeScale(1.1, 1.1);
   
    [UIView animateWithDuration:0.1 animations:^{
        alertViewWindow.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)hide
{
   [UIView animateWithDuration:0.1 animations:^{
       alertViewWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [alertViewWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        alertViewWindow.hidden = YES;
    }];
}


@end
