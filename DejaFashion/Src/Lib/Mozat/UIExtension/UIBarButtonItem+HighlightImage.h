//
//  DJBarButtonItem.h
//  DejaFashion
//
//  Created by Kevin Lin on 3/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (HighlightImage)

//@property (nonatomic, strong) UIButton *button;

+ (UIBarButtonItem *)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage target:(id)taget action:(SEL)action;

@end
