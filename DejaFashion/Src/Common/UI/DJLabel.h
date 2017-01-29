//
//  DJLabel.h
//  DejaFashion
//
//  Created by Kevin Lin on 9/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DJLabelIconVerticalMiddle,
    DJLabelIconVerticalTop,
    DJLabelIconVerticalBottom
} DJLabelIconVerticalPosition;

@interface DJLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, assign) float iconSpacing;
@property (nonatomic, assign) DJLabelIconVerticalPosition iconVerticalPosition;

- (void)setDeleteLineWithColor:(UIColor *)color;
- (void)removeDeleteLine;

@end
