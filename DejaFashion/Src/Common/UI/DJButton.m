//
//  DJButton.m
//  DejaFashion
//
//  Created by Kevin Lin on 19/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJButton.h"
#import "DejaFashion-swift.h"

@interface DJButton()

@property (nonatomic, strong) UIFont *highlightedFont;
@property (nonatomic, strong) UIFont *normalFont;

@property (nonatomic, strong) UIColor *highlightedBorderColor;
@property (nonatomic, strong) UIColor *normalBorderColor;
@property (nonatomic, strong) UIColor *selectedBorderColor;
@property (nonatomic, strong) UIColor *highlightedBackGroundColor;
@end


@implementation DJButton

-(UIColor *)btnBackgroundColor{
    if (_btnBackgroundColor == nil) {
        _btnBackgroundColor = [UIColor whiteColor];
    }
    return _btnBackgroundColor;
}

-(UIColor *)titleColor{
    if (_titleColor == nil) {
        _titleColor = [UIColor blackColor];
    }
    return _titleColor;
}

-(DJButton *)cornerRadius:(float)radius{
    self.layer.cornerRadius = radius;
    return self;
}

-(UIButton *)setWhiteTitle{
    self.titleColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor colorFromHexString:@"262729"].CGColor;
    self.layer.borderWidth = 0;
    self.titleLabel.font = [DJFont helveticaFontOfSize:14];
    self.clipsToBounds = YES;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorFromHexString:@"ffffff"] forState:UIControlStateHighlighted];
    [self setBackgroundColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[DJCommonStyle ColorRed] forState:UIControlStateHighlighted];
  //  self.highlightedBackGroundColor = [DJCommonStyle ColorRed];
    return self;
}

-(UIButton *)setBlackTitle{
    self.titleColor = [UIColor blackColor];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
    self.titleLabel.font = [DJFont helveticaFontOfSize:14];
    self.clipsToBounds = YES;
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorFromHexString:@"ffffff"] forState:UIControlStateHighlighted];
    [self setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[DJCommonStyle ColorRed] forState:UIControlStateHighlighted];
    return self;
}

-(DJButton *)withHighlightedFont:(UIFont *)font {
    self.highlightedFont = font;
    return self;
}

-(UIButton *)withFont:(UIFont *)font {
    self.normalFont = font;
    return [super withFont:font];
}

-(void)setHighlighted:(BOOL)highlighted {
    super.highlighted = highlighted;
    
    if (highlighted && self.highlightedBorderColor) {
        self.layer.borderColor = self.highlightedBorderColor.CGColor;
    }else if (self.normalBorderColor){
        self.layer.borderColor = self.normalBorderColor.CGColor;
    }else if (self.layer.borderWidth > 0){
        if (highlighted) {
            self.layer.borderColor = [UIColor colorFromHexString:@"f81f34"].CGColor;
        }else{
            self.layer.borderColor = self.titleColor.CGColor;
        }
    }
    
    
    if (highlighted && self.highlightedFont) {
        self.titleLabel.font = self.highlightedFont;
    }else if (self.normalFont) {
        self.titleLabel.font = self.normalFont;
    }
    
    if (self.highlightedBackGroundColor && highlighted){
        self.backgroundColor = self.highlightedBackGroundColor;
    }
}

-(void)setSelected:(BOOL)selected {
    super.selected = selected;
    if (selected && self.selectedBorderColor) {
        self.layer.borderColor = self.selectedBorderColor.CGColor;
    }else {
        self.layer.borderColor = self.normalBorderColor.CGColor;
    }
}

-(DJButton *)whiteTitleTransparentStyle {
    self.highlightedBorderColor = [DJCommonStyle ColorRed];
    self.normalBorderColor = [DJCommonStyle ColorEA];
    [self setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[DJCommonStyle ColorRed] forState:UIControlStateHighlighted];
    self.layer.borderWidth = 1;
    self.layer.borderColor = self.normalBorderColor.CGColor;
    self.titleLabel.font = [DJFont helveticaFontOfSize:14];
    [self setTitleColor:[DJCommonStyle ColorEA] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.clipsToBounds = YES;
    return self;
}

-(DJButton *)whiteTitleBlackStyle {
    [self setBackgroundColor:[DJCommonStyle BackgroundColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[DJCommonStyle ColorRed] forState:UIControlStateHighlighted];
    self.titleLabel.font = [DJFont mediumHelveticaFontOfSize:14];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.clipsToBounds = YES;
    return self;
}

-(DJButton *)blackTitleWhiteStyle {
    [self setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[DJCommonStyle ColorRed] forState:UIControlStateHighlighted];
    self.highlightedBorderColor = [DJCommonStyle ColorRed];
    self.normalBorderColor = [DJCommonStyle BackgroundColor];
    self.layer.borderWidth = 1;
    self.layer.borderColor = self.normalBorderColor.CGColor;
    self.titleLabel.font = [DJFont helveticaFontOfSize:14];
    [self setTitleColor:[DJCommonStyle BackgroundColor] forState:UIControlStateNormal];
    [self setTitleColor:[DJCommonStyle ColorEA] forState:UIControlStateHighlighted];
    self.clipsToBounds = YES;
    return self;
}


- (void)setButtonWithStateColor{
    [self setTitleColor:[DJCommonStyle ColorRed] forState:UIControlStateHighlighted];
    self.titleLabel.font = [DJFont fontOfSize:15];
    [self.titleLabel sizeToFit];
    if (self.titleLabel.text) {
        self.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width, 44);
    }else{
        self.frame = CGRectMake(0, 0, 44, 44);
    }
}


@end
