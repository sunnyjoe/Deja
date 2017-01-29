//
//  DJWarningBanner.h
//  DejaFashion
//
//  Created by Kevin Lin on 15/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJWarningBanner : UIView

@property (nonatomic, strong) UIFont *font;
- (void)setContent:(NSString *)content;
- (void)setIcon:(UIImage *)image;
-(void)setIconMarginX:(CGFloat)x;

@end
