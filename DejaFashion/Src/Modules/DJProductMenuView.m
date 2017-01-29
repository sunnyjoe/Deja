//
//  DJProductMenuView.m
//  DejaFashion
//
//  Created by Sun lin on 5/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJProductMenuView.h"
#import "DejaFashion-swift.h"

@implementation DJProductMenuView
{
    UILabel *titleLabel;
}
-(id)initWithFrame:(CGRect)frame withTitle:(NSString *)title menuWidth:(CGFloat)menuWidth arrowDirection:(DJProductMenuViewArrowDirection)direction
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *arrowView;
        if(direction & DJProductMenuViewArrowDirectionUp)
        {
            UIImage *arrowImage = [UIImage imageNamed:@"MenuArrowUp"];
            if(direction & DJProductMenuViewArrowDirectionCenter)
            {
                arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(130, 0, 10, 5)];
            }
            else
            {
                arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 10, 5)];
            }
            arrowView.image = arrowImage;
            [self addSubview:arrowView];
        }
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(arrowView.frame), menuWidth, 29)];
        titleLabel.font = [DJFont helveticaFontOfSize:14];
        titleLabel.backgroundColor = [UIColor blackColor];
        titleLabel.textColor = [UIColor colorFromHexString:@"eaeaea"];
        NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:title];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.firstLineHeadIndent = 6;
        [titleAttr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, title.length)];
        titleLabel.attributedText = titleAttr;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:titleLabel];
        
        self.layer.shadowRadius = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.2;
        self.layer.masksToBounds = NO;
        
        
        if(direction & DJProductMenuViewArrowDirectionDown)
        {
            UIImage *arrowImage = [UIImage imageNamed:@"MenuArrowDown"];
            if(direction & DJProductMenuViewArrowDirectionCenter)
            {
                arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(130, frame.size.height, 10, 5)];
            }
            else
            {
                arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(60, frame.size.height, 10, 5)];
            }
            arrowView.image = arrowImage;
            [self addSubview:arrowView];
        }
    }
    return self;
}



-(CGFloat)menuListY
{
    return CGRectGetMaxY(titleLabel.frame);
}

@end
