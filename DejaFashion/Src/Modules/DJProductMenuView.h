//
//  DJProductMenuView.h
//  DejaFashion
//
//  Created by Sun lin on 5/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDJMenuArrowX  60

typedef enum DJProductMenuViewArrowDirection {
    DJProductMenuViewArrowDirectionUp = 0x01,
    DJProductMenuViewArrowDirectionDown = 0x02,
    DJProductMenuViewArrowDirectionCenter = 0x04
}DJProductMenuViewArrowDirection;

@interface DJProductMenuView : UIView

-(id)initWithFrame:(CGRect)frame withTitle:(NSString *)title menuWidth:(CGFloat)menuWidth arrowDirection:(DJProductMenuViewArrowDirection)direction;
-(CGFloat)menuListY;
@end
