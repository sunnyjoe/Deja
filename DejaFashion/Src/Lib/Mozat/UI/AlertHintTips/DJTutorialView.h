//
//  DJTutorialView.h
//  DejaFashion
//
//  Created by Sun lin on 27/3/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum DJTurorialViewArrowDirection {
    DJTurorialViewArrowNone = 0,
    DJTurorialViewArrowDirectionTop = 1,
    DJTurorialViewArrowDirectionBottom = 2,
    DJTurorialViewArrowDirectionLeft = 3,
    DJTurorialViewArrowDirectionRight = 4,
    DJTurorialViewArrowDirectionTopRight = 5,
    DJTurorialViewArrowDirectionTopLeft = 6,
    DJTurorialViewArrowDirectionBottomLeft = 7
}DJTurorialViewArrowDirection;


@class DJTutorialView;

@protocol DJTutorialViewDelegate <NSObject>

@optional
-(void)tutorialViewDidDisappear:(UIView *)tutorialView;

@end

@interface DJTutorialView : UIView

@property(nonatomic, weak) id<DJTutorialViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame direction:(DJTurorialViewArrowDirection)direction;

-(void)setText:(NSString *)text;

-(void)setBackgroundColor:(UIColor *)color;
-(void)setTextColor:(UIColor *)color;

@property(nonatomic, strong) DJLabel *label;


@end
