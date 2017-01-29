//
//  DJLabel.m
//  DejaFashion
//
//  Created by Kevin Lin on 9/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJLabel.h"

#define kDJLabelDeleteLineTag 2000

@interface DJLabel ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation DJLabel

- (void)drawRect:(CGRect)rect
{
    UIEdgeInsets insets = { self.insets.top, self.insets.left + (self.icon ? self.icon.size.width + self.iconSpacing : 0), self.insets.bottom, self.insets.right };
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIView *deleteLine = [self viewWithTag:kDJLabelDeleteLineTag];
    deleteLine.frame = CGRectMake(-1, (self.frame.size.height - 1) / 2, self.frame.size.width + 2, 0.5);
    
    float iconY = (self.frame.size.height - self.icon.size.height) / 2;
    if (self.iconVerticalPosition == DJLabelIconVerticalTop) {
        iconY = 0;
    }
    else if (self.iconVerticalPosition == DJLabelIconVerticalBottom) {
        iconY = self.frame.size.height - self.icon.size.height;
    }
    self.iconView.frame = CGRectMake(self.insets.left, iconY,
                                     self.icon.size.width, self.icon.size.height);
}


- (void)setIcon:(UIImage *)icon
{
    _icon = icon;
    if (!self.iconView) {
        self.iconView = [UIImageView new];
        [self insertSubview:self.iconView atIndex:0];
    }
    self.iconView.image = icon;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setDeleteLineWithColor:(UIColor *)color
{
    UIView *deleteLine = [self viewWithTag:kDJLabelDeleteLineTag];
    if (!deleteLine) {
        deleteLine = [UIView new];
        deleteLine.tag = kDJLabelDeleteLineTag;
        [self addSubview:deleteLine];
        [self setNeedsLayout];
    }
    deleteLine.backgroundColor = color;
}

- (void)removeDeleteLine
{
    [[self viewWithTag:kDJLabelDeleteLineTag] removeFromSuperview];
}

- (void)sizeToFit
{
    [super sizeToFit];
    CGRect frame = self.frame;
    if (self.icon) {
        frame.size.width += self.icon.size.width + self.iconSpacing;
        frame.size.height = MAX(frame.size.height, self.icon.size.height);
    }
    frame.size.width += self.insets.left + self.insets.right;
    frame.size.height += self.insets.top + self.insets.bottom;
    self.frame = frame;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    // layoutSubviews is never called in iOS 8.0.0, it should be called programmly after frame changed
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        NSOperatingSystemVersion ios8_1_0 = (NSOperatingSystemVersion){8, 1, 0};
        if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios8_1_0]) {
            [self layoutSubviews];
        }
    }
}

- (float)iconSpacing
{
    if (!_iconSpacing) {
        return 2;
    }
    return _iconSpacing;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.iconView.tintColor = tintColor;
}

@end
