//
//  DJBarButtonItem.m
//  DejaFashion
//
//  Created by Kevin Lin on 3/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "UIBarButtonItem+HighlightImage.h"

@implementation UIBarButtonItem (HighlightImage)

+ (UIBarButtonItem *)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage target:(id)target action:(SEL)action
{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    UIBarButtonItem *one = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    DebugLayer(button, 1.0, [UIColor redColor].CGColor);
    
    return one;
}

@end
