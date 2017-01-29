//
//  UIImageView + MOAdditions
//  Mozat
//
//  Created by zhenling on 10/6/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Mozat)

-(void)removeAllSubViews;
-(void)removeSubViewByTag:(int)tag;
- (UIViewController*)viewController;

-(UIImage *)getImageFromView:(float)scale;

- (void)addTapGestureTarget:(id)target action:(SEL)action;
- (void)addLongPressGestureTarget:(id)target action:(SEL)action;
- (void)removeLongPressGesture;

@end