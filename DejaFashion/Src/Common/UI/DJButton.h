//
//  DJButton.h
//  DejaFashion
//
//  Created by Kevin Lin on 19/11/14.
//  Copyright (c) 2014 ;. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJButton : UIButton

@property(nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;
@property(nonatomic, strong) UIView *appendView;

@property (nonatomic, strong) UIColor *btnBackgroundColor;
@property (nonatomic, strong) UIColor *titleColor;

// deperated
- (void)setButtonWithStateColor;
// deperated

-(DJButton *)cornerRadius:(float)radius;
-(DJButton *)setWhiteTitle;
-(DJButton *)setBlackTitle;

-(DJButton *)withHighlightedFont:(UIFont *)font;
-(UIButton *)withFont:(UIFont *)font;

// some styles to init button
-(DJButton *)whiteTitleTransparentStyle;
-(DJButton *)whiteTitleBlackStyle;
//-(DJButton *)blackTitleTransparentStyle;
-(DJButton *)blackTitleWhiteStyle;


@end
