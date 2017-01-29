//
//  DJTutorialView.m
//  DejaFashion
//
//  Created by Sun lin on 27/3/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJTutorialView.h"
#import "DejaFashion-swift.h"

@interface DJTutorialView()

@property(nonatomic, strong) UIView  *bgView;
@property(nonatomic, assign) DJTurorialViewArrowDirection direction;
@property(nonatomic, strong) CAShapeLayer *triangleLayer;

@end

@implementation DJTutorialView


-(id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame direction:DJTurorialViewArrowDirectionTop];
}

-(void)setText:(NSString *)text
{
    [self.label setText:text];
}

-(id)initWithFrame:(CGRect)frame direction:(DJTurorialViewArrowDirection)direction
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.direction = direction;
        
        self.bgView = [UIView new];
        self.bgView.backgroundColor = [DJCommonStyle backgroundColorWithAlpha:0.95];
        self.bgView.frame = self.bounds;
    
        self.label = [DJLabel new];
        self.label.textAlignment =  NSTextAlignmentCenter;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.numberOfLines = 0;
        self.label.frame = self.bounds;
        self.label.insets = UIEdgeInsetsMake(5, 5, 5, 5);
        
        self.label.font = [DJFont tutorialFont:17.0];
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.bgView];
        [self addSubview:self.label];
        self.label.userInteractionEnabled = YES;
        [self.label addTapGestureTarget:self action:@selector(tapLabel:)];
    }
    
    [self drawTriangle];
    return self;
}

-(void)setTextColor:(UIColor *)color {
    [self.label setTextColor:color];
}

-(void)setBackgroundColor:(UIColor *)color {
    [self.bgView setBackgroundColor:color];
    self.triangleLayer.fillColor = color.CGColor;
}

- (void)drawTriangle {
    CGPoint A;
    CGPoint B;
    CGPoint C;
    
    float width = 9 * kIphoneSizeScale;
    switch (self.direction) {
        case DJTurorialViewArrowNone:
        {
            return;
        }
        case DJTurorialViewArrowDirectionTop:
        {
            A = CGPointMake(self.frame.size.width / 2, -width);
            B = CGPointMake(self.frame.size.width / 2 - width / 2, 0);
            C = CGPointMake(self.frame.size.width / 2 + width / 2, 0);
            break;
        }
        case DJTurorialViewArrowDirectionBottom:
        {
            A = CGPointMake(self.frame.size.width / 2, self.frame.size.height + width);
            B = CGPointMake(self.frame.size.width / 2 - width / 2, self.frame.size.height);
            C = CGPointMake(self.frame.size.width / 2 + width / 2, self.frame.size.height);
            break;
        }
        case DJTurorialViewArrowDirectionLeft:
        {
            A = CGPointMake(-width, self.frame.size.height / 2);
            B = CGPointMake(0, self.frame.size.height / 2 - width / 2);
            C = CGPointMake(0, self.frame.size.height / 2 + width / 2);
            break;
        }
        case DJTurorialViewArrowDirectionRight:
        {
            A = CGPointMake(self.frame.size.width + width, self.frame.size.height / 2);
            B = CGPointMake(self.frame.size.width, self.frame.size.height / 2 - width / 2);
            C = CGPointMake(self.frame.size.width, self.frame.size.height / 2 + width / 2);
            break;
        }
        case DJTurorialViewArrowDirectionTopRight:
        {
            A = CGPointMake(self.frame.size.width * 3 / 4, -width);
            B = CGPointMake(self.frame.size.width * 3 / 4 - width / 2, 0);
            C = CGPointMake(self.frame.size.width * 3 / 4 + width / 2, 0);
            break;
        }
        case DJTurorialViewArrowDirectionTopLeft:
        {
            A = CGPointMake(self.frame.size.width / 6, -width);
            B = CGPointMake(self.frame.size.width / 6 - width / 2, 0);
            C = CGPointMake(self.frame.size.width / 6 + width / 2, 0);
            break;
        }
        case DJTurorialViewArrowDirectionBottomLeft:
        {
            A = CGPointMake(self.frame.size.width / 4, self.frame.size.height + width);
            B = CGPointMake(self.frame.size.width / 4 - width / 2, self.frame.size.height);
            C = CGPointMake(self.frame.size.width / 4 + width / 2, self.frame.size.height);
            break;
        }
        default:
            return;
    }

    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:A];
    [trianglePath addLineToPoint:B];
    [trianglePath addLineToPoint:C];
    [trianglePath closePath];
    
    CAShapeLayer *triangleLayer = [CAShapeLayer layer];
    triangleLayer.fillColor = [DJCommonStyle backgroundColorWithAlpha:0.95].CGColor;

    [triangleLayer setPath:trianglePath.CGPath];
    self.triangleLayer = triangleLayer;
    [self.layer addSublayer:triangleLayer];
}

- (void)tapLabel: (UITapGestureRecognizer *)rec {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [self removeFromSuperview];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(tutorialViewDidDisappear:)])
        {
            [self.delegate tutorialViewDidDisappear:self];
        }
    });
    return self;
}
@end
