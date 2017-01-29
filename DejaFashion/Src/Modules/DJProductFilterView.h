//
//  DJProductFilterView.h
//  DejaFashion
//
//  Created by DanyChen on 28/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DJProductSearchStatusAll = 0,
    DJProductSearchStatusSales = 1,
    DJProductSearchStatusNewArrival = 2
} DJProductSearchStatusType;

@class DJProductFilterView;
@protocol DJProductFilterViewDelegate <NSObject>

-(void)productFilterViewDone: (DJProductFilterView *)view;
-(void)productFilterBackgroundDidClick: (DJProductFilterView *)view;

@end

@interface DJProductFilterView : UIView

@property (nonatomic, assign) DJProductSearchStatusType searchStatus;
@property (nonatomic, assign) NSInteger lowerPrice;
@property (nonatomic, assign) NSInteger higherPrice;
@property (nonatomic, weak) id<DJProductFilterViewDelegate> delegate;

@end

