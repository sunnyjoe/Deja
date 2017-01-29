//
//  DJBasicViewController.h
//  DejaFashion
//
//  Created by Sun lin on 14/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//
@import Reachability;
#import <UIKit/UIKit.h>
#import "MOBasicViewController.h"
#import "DJEmptyView.h"


@interface DJBasicViewController : MOBasicViewController

-(UIColor *)navigationBarTextColor;


@property (nonatomic, assign) BOOL navigationBarBorderHidden;
@property (nonatomic, assign) BOOL showNavigationBarAnimated;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) BOOL isViewAppeared;
@property (nonatomic, strong) UIBarButtonItem *homeItem;
 
@property (nonatomic, assign) BOOL showBackBtn;
- (instancetype)init;

- (BOOL)canScrollToTopWhenTapTitle;
- (void)goBack;

- (void)setCloseLeftBarItem;
- (void)setCancelLeftBarItem;
-(void)addWhiteBackButton;

- (float) emptyViewYOffset; 
- (void) showNetworkUnavailableView;
- (void) hideNetworkUnavailableView;
- (void) emptyViewButtonDidClick:(DJEmptyView *)emptyView;

- (void) showSlideDownTip: (NSString *)text;
- (void) showSlideDownTip: (NSString *)text icon :(UIImage *)icon;

- (void)cancelBtnDidTap;
@end