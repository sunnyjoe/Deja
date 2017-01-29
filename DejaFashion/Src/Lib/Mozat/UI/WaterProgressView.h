//
//  CCProgressView.h
//  ProgressViewDemo
//
//  Created by mr.cao on 14-5-27.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaterProgressView;
@protocol WaterProgressViewDelegate <NSObject>

- (void)waterProgressViewDidClick:(WaterProgressView *)waterProgressView;

@end

@interface WaterProgressView : UIView
@property(nonatomic, weak) id <WaterProgressViewDelegate> delegate;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
