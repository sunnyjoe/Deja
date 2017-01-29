//
//  DJEmptyPage.m
//  DejaFashion
//
//  Created by DanyChen on 3/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import "DJEmptyView.h"

@interface DJEmptyView()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *firstLabel;
@property (nonatomic,strong) UILabel *firstDownLabel;

@property (nonatomic,strong) UILabel *secondLabel;
@property (nonatomic,strong) UILabel *secondDownLabel;

@property (nonatomic,strong) UIButton *emptyBtn;
@end


@implementation DJEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.firstLabel = [UILabel new];
        [self addSubview:self.firstLabel];
        self.firstLabel.numberOfLines = 0;
        self.firstLabel.textAlignment = NSTextAlignmentCenter;
        [self.firstLabel setFont:[DJFont mediumHelveticaFontOfSize:18]];
        [self.firstLabel setTextColor:[UIColor colorFromHexString:@"414141"]];
        
        self.secondLabel = [UILabel new];
        [self addSubview:self.secondLabel];
        self.secondLabel.numberOfLines = 0;
        self.secondLabel.textAlignment = NSTextAlignmentCenter;
        [self.secondLabel setFont:[DJFont contentFontOfSize:16]];
        [self.secondLabel setTextColor:[UIColor colorFromHexString:@"818181"]];
        
        self.emptyBtn = [UIButton new];
        [self.emptyBtn addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.emptyBtn setImage:[UIImage imageNamed:@"FBLoginNormal"] forState:UIControlStateNormal];
        [self.emptyBtn setImage:[UIImage imageNamed:@"FBLoginPress"] forState:UIControlStateHighlighted];
        [self addSubview:self.emptyBtn];
        
        [self addSubview:self.imageView = [UIImageView new]];
    }
    return self;
}

-(void)layoutSubviews{
    self.imageView.frame = CGRectMake(self.frame.size.width / 2 - self.imageView.image.size.width / 2, 100 * kIphoneSizeScale, self.imageView.image.size.width, self.imageView.image.size.height);
    [self.firstLabel sizeToFit];
    float y = 0;
    CGSize firstLabelSize = self.firstLabel.frame.size;
    self.firstLabel.frame = CGRectMake(10, 220 * kIphoneHeightScale, self.frame.size.width - 20, firstLabelSize.height);
    y += self.firstLabel.frame.size.height + self.firstLabel.frame.origin.y;
    
    if (self.firstDownLabel) {
        y += 0;
        [self.firstDownLabel sizeToFit];
        self.firstDownLabel.frame = CGRectMake(10, y, self.frame.size.width - 20, firstLabelSize.height);
        y += self.firstDownLabel.frame.size.height;
    }
    y += 7;
    
    [self.secondLabel sizeToFit];
    CGSize secondLabelSize = self.firstLabel.frame.size;
    self.secondLabel.frame = CGRectMake(10, y, self.frame.size.width - 20, secondLabelSize.height);
    y += self.secondLabel.frame.size.height;
    
    if (self.secondDownLabel) {
        y += 0;
        [self.secondDownLabel sizeToFit];
        self.secondDownLabel.frame = CGRectMake(10, y, self.frame.size.width - 20, secondLabelSize.height);
        y += self.secondDownLabel.frame.size.height;
    }
    y += 14;
    if (self.emptyBtn.imageView.image) {
        self.emptyBtn.frame = CGRectMake(self.frame.size.width / 2 - 195 / 2, y, 195, 42);
    }else {
        self.emptyBtn.frame = CGRectMake(self.frame.size.width / 2 - 150 / 2, y, 150, 32);
    }
}

-(void)setFirstLine:(NSString *)firstLine{
    self.firstLabel.text = [firstLine uppercaseString];
    [self setNeedsLayout];
}

-(void)setSecondLine:(NSString *)secondLine{
    self.secondLabel.text = secondLine;
    [self setNeedsLayout];
}

-(void)setFirstLineDown:(NSString *)firstLineDown{
    if (!self.firstDownLabel) {
        self.firstDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.firstDownLabel.numberOfLines = 0;
        self.firstDownLabel.textAlignment = NSTextAlignmentCenter;
        [self.firstDownLabel setFont:[DJFont contentFontOfSize:21]];
        [self.firstDownLabel setTextColor:[UIColor colorFromHexString:@"818181"]];
        [self addSubview:self.firstDownLabel];
    }
    self.firstDownLabel.text = firstLineDown;
    [self setNeedsLayout];
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self setNeedsLayout];
}

-(void)setSecondLineDown:(NSString *)secondLineDown{
    if (!self.secondDownLabel) {
        self.secondDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.secondDownLabel.numberOfLines = 0;
        self.secondDownLabel.textAlignment = NSTextAlignmentCenter;
        [self.secondDownLabel setFont:[DJFont contentFontOfSize:16]];
        [self.secondDownLabel setTextColor:[UIColor colorFromHexString:@"818181"]];
        [self addSubview:self.secondDownLabel];
    }
    self.secondDownLabel.text = secondLineDown;
    [self setNeedsLayout];
}

-(void)didClickButton: (UIButton *)button{
    [self.emptyViewDelegate emptyViewButtonDidClick:self];
}

+ (DJEmptyView *) netWorkFailView {
    DJEmptyView *emptyView = [DJEmptyView new];
    emptyView.image = [UIImage imageNamed:@"NetworkErrorImage"];
    emptyView.firstLine = MOLocalizedString(@"NETWORK UNAVAILABLE", @"");
    emptyView.secondLine = MOLocalizedString(@"please check your connection", @"");
    emptyView.secondLineDown = MOLocalizedString(@"and try again", @"");
    
    DJButton *btn = [DJButton new];
    [btn whiteTitleBlackStyle];
    [btn setTitle:MOLocalizedString(@"Refresh", @"") forState:UIControlStateNormal];
    emptyView.emptyBtn = btn;
    [emptyView.emptyBtn addTarget:emptyView action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [emptyView addSubview:emptyView.emptyBtn];
    return emptyView;
}

@end
