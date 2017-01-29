//
//  DJBasicViewController.m
//  DejaFashion
//
//  Created by Sun lin on 14/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJBasicViewController.h"
#import "DejaFashion-Swift.h"
#import "DJWarningBanner.h"

@interface DJBasicViewController () <UIGestureRecognizerDelegate, DJEmptyViewDelegate>

@property (nonatomic, strong) DJEmptyView *noNetworkView;
@property (nonatomic, strong) UIButton *backView;
@property (nonatomic, strong) DJWarningBanner *slideDownTip;

@property (nonatomic, assign) BOOL viewHasAppearOnce;
//@property (nonatomic, strong)Dialog *dialog;
@end

@implementation DJBasicViewController
@synthesize title = _title;

- (instancetype)init
{
    if (self = [super init]) {
        self.showBackBtn = false;
        self.hidesBottomBarWhenPushed = YES;
        self.viewHasAppearOnce = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:@"262729"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar hideBottomHairline];
    
    self.titleLabel.font = [DJFont mediumHelveticaFontOfSize:15];
    self.titleLabel.frame = CGRectMake(0, 0, 0, 30);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = self.titleLabel;
    self.titleLabel.textColor = [self navigationBarTextColor];
    [self.navigationItem.titleView addTapGestureTarget:self action:@selector(tapTitle:)];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    
    self.backView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44.0f)];
}

-(void)addWhiteBackButton{
    UIControl *backControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 33, 44.0f)];
    [self.backView addSubview:backControl];
    [backControl addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0, 13, 23, 19);
    [self.backButton setImage:[UIImage imageNamed:@"WhiteBackIconNormal"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.backButton];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.backView];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(UIColor *)navigationBarTextColor{
    return [DJCommonStyle ColorEA];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isViewAppeared = YES;
    [super viewWillAppear:animated];
    [[DJStatisticsLogic instance] beginLogPageView:NSStringFromClass(self.class)];
    if (self.showNavigationBarAnimated) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    
    if (!self.viewHasAppearOnce) {
        BOOL shouldAdd = false;
        if (self.navigationController) {
            if (self.navigationController.viewControllers[0] != self) {
                shouldAdd = true;
            }
        }
        if (shouldAdd || self.showBackBtn) {
            [self addWhiteBackButton];
        }
    }
    self.viewHasAppearOnce = true;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[DJStatisticsLogic instance] endLogPageView:NSStringFromClass(self.class)];
    self.isViewAppeared = NO;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    return _titleLabel;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

- (void)tapTitle: (UITapGestureRecognizer *)r {
    if (![self canScrollToTopWhenTapTitle]) {
        return;
    }
    
    UIScrollView *scrollView = [self findSubScrollView:self.view];
    if (scrollView) {
        [scrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)showNetworkUnavailableView {
    if (!self.noNetworkView) {
        self.noNetworkView = [DJEmptyView netWorkFailView];
        self.noNetworkView.emptyViewDelegate = self;
    }
    [self.view addSubview:self.noNetworkView];
    self.noNetworkView.frame = CGRectMake(0, [self emptyViewYOffset], self.view.frame.size.width, self.view.frame.size.height);
    self.noNetworkView.hidden = NO;
}

- (void) hideNetworkUnavailableView {
    self.noNetworkView.hidden = YES;
}

-(UIScrollView *)findSubScrollView: (UIView *)originView {
    if ([originView isKindOfClass:[UIScrollView class]] && !originView.hidden) {
        UIScrollView *scrollView = (UIScrollView *)originView;
        if (scrollView.contentOffset.y > 0) {
            return scrollView;
        }
    }
    NSArray *views = originView.subviews;
    if (views.count) {
        for (UIView *v in views) {
            if (!v.hidden) {
                UIScrollView *findView = [self findSubScrollView:v];
                if (findView) {
                    return findView;
                }
            }
        }
    }
    return nil;
}

-(BOOL)canScrollToTopWhenTapTitle {
    return YES;
}

-(void)emptyViewButtonDidClick:(DJEmptyView *)emptyView {
    
}

-(float)emptyViewYOffset {
    return 0;
}

-(void)showSlideDownTip:(NSString *)text {
    [self showSlideDownTip:text icon:[UIImage imageNamed:@"Speaker"]];
}

-(void)showSlideDownTip:(NSString *)text icon :(UIImage *)icon{
    if (!self.slideDownTip) {
        self.slideDownTip = [DJWarningBanner new];
        self.slideDownTip.frame = CGRectMake(0, 45, [UIScreen mainScreen].bounds.size.width, 35);
        self.slideDownTip.hidden = YES;
        self.slideDownTip.contentMode =  UIViewContentModeLeft;
    }
    
    [self.slideDownTip setIcon:icon];
    [self.slideDownTip setContent:text];
    
    if (!self.slideDownTip.hidden) {
        return;
    }
    
//    self.slideDownTip.frame = CGRectMake(0, 35, [UIScreen mainScreen].bounds.size.width, 35);
    self.slideDownTip.hidden = NO;
    [self.view addSubview:self.slideDownTip];
    __weak DJWarningBanner *weakBanner = self.slideDownTip;
    weakBanner.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //        weakBanner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 38);
        weakBanner.alpha = 1;
    } completion:^(BOOL completion){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                weakBanner.frame = CGRectMake(0, -38, [UIScreen mainScreen].bounds.size.width, 38);
                weakBanner.alpha = 0;
            } completion:^(BOOL completion){
                weakBanner.hidden = YES;
            }];
        });
    }];
}

-(void)setCloseLeftBarItem {
    DJButton *cancelBtn = [DJButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setButtonWithStateColor];
    UIImage *closeImage = [UIImage imageNamed:@"CloseIcon"];
    closeImage = [UIImage imageNamed:@"WhiteCloseIcon"];
    [cancelBtn setImage:closeImage forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"CloseIconPressed"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelBtnDidTap) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(-11, cancelBtn.frame.origin.y, cancelBtn.frame.size.width, cancelBtn.frame.size.height);
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44.0f)];
    [backView addSubview:cancelBtn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
}

- (void)setCancelLeftBarItem {
    DJButton *cancelBtn = [DJButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setButtonWithStateColor];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnDidTap) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(-11, cancelBtn.frame.origin.y, 80, cancelBtn.frame.size.height);
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44.0f)];
    [backView addSubview:cancelBtn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
}

-(void)cancelBtnDidTap {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

@end
