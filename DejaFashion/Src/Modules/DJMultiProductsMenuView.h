//
//  DJMultiProductsMenuView.h
//  DejaFashion
//
//  Created by Sun lin on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJProductMenuView.h"

#define kDJMultiProductMenuCellWidth  70
#define kDJMultiProductMenuHeight  90
@class DJMultiProductsMenuView;
@class Clothes;

@protocol DJMultiProductsMenuViewDelegate <NSObject>

@optional

- (void)productsMenuView:(DJMultiProductsMenuView *)productMenuView didSelectProduct:(Clothes *)product;

@end

@interface DJMultiProductsMenuView : DJProductMenuView

@property(nonatomic, weak) id<DJMultiProductsMenuViewDelegate> delegate;
@property (atomic,assign) CGPoint *point;
- (instancetype)initWithFrame:(CGRect)frame products:(NSArray *)products arrowDirection:(DJProductMenuViewArrowDirection)direction;
@end
