//
//  DJSingleProductMenuView.h
//  DejaFashion
//
//  Created by Sun lin on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJProductMenuView.h"


#define kDJSigleProductMenuWidth  160
#define kDJSigleProductMenuHeight  90

@class DJSingleProductMenuView;
@class Clothes;
@class DJModelView;
@protocol DJSingleProductMenuViewDelegate <NSObject>

@optional
- (void)didClickSingleProductMenuTuck:(Clothes *)product;
- (void)didClickSingleProductMenuDetail:(Clothes *)product;
- (void)didClickSingleProductMenuTakeOff:(Clothes *)product;

@end

@interface DJSingleProductMenuView : DJProductMenuView

@property(nonatomic, weak) id<DJSingleProductMenuViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame product:(Clothes *)product arrowDirection:(DJProductMenuViewArrowDirection)direction showTuckOption:(BOOL)showTuck tuckValue:(NSString *)tuckValue showTakeoff:(BOOL)showTakeoff showDetail:(BOOL)showDetail;
@end
