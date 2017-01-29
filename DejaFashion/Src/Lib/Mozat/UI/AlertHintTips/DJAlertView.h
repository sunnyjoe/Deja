//
//  DJAlertView.h
//  DejaFashion
//
//  Created by Kevin Lin on 21/1/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DJAlertView;

@protocol DJAlertViewDelegate <NSObject>

- (void)alertView:(DJAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface DJAlertView : UIView

@property (nonatomic, weak) id<DJAlertViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<DJAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitlesArray:(NSArray *)otherButtonTitlesArray;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<DJAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)show;
- (void)hide;

@end
