//
//  DJWarningBanner.m
//  DejaFashion
//
//  Created by Kevin Lin on 15/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJWarningBanner.h"
#import "DJFont.h"
#import "UIColor+MOAdditions.h"

@interface DJWarningBanner ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, assign) CGFloat iconX;

@end

@implementation DJWarningBanner

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.iconX = 23;
        self.backgroundColor = [UIColor colorFromHexString:@"262729" alpha:0.7];
        self.iconView = [UIImageView new];//[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WarningIcon"]];
        [self addSubview:self.iconView];
        
        self.contentLabel = [UILabel new];
        self.contentLabel.font = [DJFont contentFontOfSize:14];
        self.contentLabel.textColor = [UIColor colorFromHexString:@"ffffff"];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)setIcon:(UIImage *)image {
    self.iconView.image = image;
}

- (void)setContent:(NSString *)content
{
    self.contentLabel.text = content;
    self.contentLabel.font = self.font;
}

-(void)setIconMarginX:(CGFloat)x
{
    self.iconX = x;
}


-(void)layoutSubviews
{
    [self.contentLabel sizeToFit];
    if (self.contentMode == UIViewContentModeLeft) {
        
        self.iconView.frame = CGRectMake(self.iconX, (self.frame.size.height - self.iconView.image.size.height) / 2,
                                         self.iconView.image.size.width, self.iconView.image.size.height);
        self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 10,
                                             (self.frame.size.height - self.contentLabel.frame.size.height) / 2,
                                             self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
    }
    else
    {
        self.contentLabel.frame = CGRectMake((self.frame.size.width - self.contentLabel.frame.size.width) / 2,
                                             (self.frame.size.height - self.contentLabel.frame.size.height) / 2,
                                             self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
        self.iconView.frame = CGRectMake(self.contentLabel.frame.origin.x - self.iconView.image.size.width - 10,
                                         (self.frame.size.height - self.iconView.image.size.height) / 2,
                                         self.iconView.image.size.width, self.iconView.image.size.height);
    }
}

@end
