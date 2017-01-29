//
//  UIImageView + MOAdditions.m
//  Mozat
//
//  Created by zhenling on 10/6/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "UIView+Mozat.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>


@implementation UIView (Mozat)


-(void)removeAllSubViews
{
	NSArray *viewsToRemove = self.subviews;
	for (UIView *v in viewsToRemove)
    {
		[v removeFromSuperview];
	}
}

-(void)removeSubViewByTag:(int)tag
{
	NSArray *viewsToRemove = self.subviews;
	for (UIView *v in viewsToRemove)
    {
		if(v.tag == tag)
        {
            [v removeFromSuperview];
			return;
		}
    }
}


- (UIViewController*)viewController
{
	for (UIView* next = [self superview]; next; next = next.superview)
    {
		UIResponder* nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]])
        {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

-(UIImage *)getImageFromView:(float)scale
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)addTapGestureTarget:(id)target action:(SEL)action
{
    self.userInteractionEnabled = YES;
    if (self.gestureRecognizers.count) {
        for (int i = 0; i < self.gestureRecognizers.count; i++) {
            UIGestureRecognizer *reg = self.gestureRecognizers[i];
            if ([reg isMemberOfClass:[UITapGestureRecognizer class]]) {
                [self removeGestureRecognizer:reg];
            }
        }
    }
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
}

-(void)removeLongPressGesture {
    if (self.gestureRecognizers.count) {
        for (int i = 0; i < self.gestureRecognizers.count; i++) {
            UIGestureRecognizer *reg = self.gestureRecognizers[i];
            if ([reg isMemberOfClass:[UILongPressGestureRecognizer class]]) {
                [self removeGestureRecognizer:reg];
            }
        }
    }
}

-(void)addLongPressGestureTarget:(id)target action:(SEL)action
{
    self.userInteractionEnabled = YES;
    [self removeLongPressGesture];
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:target action:action]];
}

@end
