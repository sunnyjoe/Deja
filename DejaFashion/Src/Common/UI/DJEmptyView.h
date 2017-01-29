//
//  DJEmptyPage.h
//  DejaFashion
//
//  Created by DanyChen on 3/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DJEmptyView;

@protocol DJEmptyViewDelegate <NSObject>

- (void)emptyViewButtonDidClick: (DJEmptyView *)emptyView;

@end

@interface DJEmptyView : UIView

+ (DJEmptyView *) netWorkFailView;

@property (nonatomic,strong) NSString *firstLine;
@property (nonatomic,strong) NSString *firstLineDown;

@property (nonatomic,strong) NSString *secondLine;
@property (nonatomic,strong) NSString *secondLineDown;

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,strong) id<DJEmptyViewDelegate> emptyViewDelegate;

-(void)didClickButton: (UIButton *)button;

@end
