//
//  DJRefreshContainerView.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 8/10/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import "DJRefreshContainerView.h"
#import "DejaFashion-swift.h"

static float kDJPulltoRefreshDistance = 60;
static float kDJRefreshDotRadius = 7;
static float kDJRefreshDotMaxScale = 1.3;
static float kDJDotSpacing = 8;
static float kDJRefreshScrollViewBottomMargin = 30;

@interface DJRefreshView : UIView
@property (strong, nonatomic) UIImageView *redDot1;
@property (strong, nonatomic) UIImageView *redDot2;
@property (strong, nonatomic) UIImageView *redDot3;
@property (strong, nonatomic) UIColor *dotColor;
@end

@implementation DJRefreshView
-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initDotsView:frame];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self initDotsFrame];
}

-(void)initDotsView:(CGRect)frame{
    self.redDot1 = [self createRefreshDot];
    self.redDot2 = [self createRefreshDot];
    self.redDot3 = [self createRefreshDot];
    
    [self initDotsFrame];
}

-(void)initDotsFrame{
    self.redDot1.frame = CGRectMake(self.frame.size.width / 2 - kDJRefreshDotRadius * 3 / 2 - kDJDotSpacing, self.frame.size.height / 2, kDJRefreshDotRadius, kDJRefreshDotRadius);
    self.redDot2.frame = CGRectMake(self.frame.size.width / 2 - kDJRefreshDotRadius / 2, self.frame.size.height / 2, kDJRefreshDotRadius, kDJRefreshDotRadius);
    self.redDot3.frame = CGRectMake(self.frame.size.width / 2 + kDJRefreshDotRadius / 2 + kDJDotSpacing, self.frame.size.height / 2, kDJRefreshDotRadius, kDJRefreshDotRadius);
}

-(UIImageView *)createRefreshDot{
    UIImageView * redDot = [UIImageView new];
    redDot.backgroundColor = self.dotColor?: DJCommonStyle.ColorRed;
    redDot.layer.cornerRadius = kDJRefreshDotRadius / 2;
    [self addSubview:redDot];
    
    return redDot;
}

-(void)setDotColor:(UIColor *)dotColor{
    _dotColor = dotColor;
    
    [self removeAllSubViews];
    [self initDotsView:self.frame];
}

-(void)startLoadingAnimation{
    [self resetAnimation];
    [self resetTransform];
    [self initDotsFrame];
    float duration = 0.3;
    CGAffineTransform scale = CGAffineTransformMakeScale(kDJRefreshDotMaxScale, kDJRefreshDotMaxScale);
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse |UIViewAnimationOptionCurveEaseInOut | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1 animations:^{
            self.redDot1.transform = scale;
        }];
    } completion:nil];
    
    [UIView animateKeyframesWithDuration:duration delay:(duration / 2) options:UIViewKeyframeAnimationOptionAutoreverse|UIViewAnimationOptionCurveEaseInOut | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1 animations:^{
            self.redDot2.transform = scale;
        }];
    } completion:nil];
    
    [UIView animateKeyframesWithDuration:duration delay:duration options:UIViewKeyframeAnimationOptionAutoreverse|UIViewAnimationOptionCurveEaseInOut | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1 animations:^{
            self.redDot3.transform = scale;
        }];
    } completion:nil];
}

-(void)resetTransform{
    self.redDot1.transform = CGAffineTransformIdentity;
    self.redDot2.transform = CGAffineTransformIdentity;
    self.redDot3.transform = CGAffineTransformIdentity;
}

-(void)resetAnimation{
    [self.redDot1.layer removeAllAnimations];
    [self.redDot2.layer removeAllAnimations];
    [self.redDot3.layer removeAllAnimations];
}

-(void)zeroScaleDots{
    self.redDot1.transform = CGAffineTransformMakeScale(0, 0);
    self.redDot2.transform = CGAffineTransformMakeScale(0, 0);
    self.redDot3.transform = CGAffineTransformMakeScale(0, 0);
}

-(void)fadeAnimation:(void (^)())completionBegin{
    [self resetAnimation];
    [self resetTransform];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        self.redDot1.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL completion){
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            self.redDot2.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL completion){
            [UIView animateWithDuration:0.1  delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
                self.redDot3.transform = CGAffineTransformMakeScale(0.01, 0.01);
            } completion:^(BOOL completion){
                if (completionBegin) {
                    completionBegin();
                    [self resetAnimation];
                    [self resetTransform];
                }
            }];
        }];
    }];
}
@end


@interface DJRefreshContainerView ()
@property (strong, nonatomic) DJRefreshView *topRefreshView;
@property (strong, nonatomic) DJRefreshView *bottomRefreshView;

@property (assign, nonatomic) BOOL animating;
@end

@implementation DJRefreshContainerView

-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.bounce = YES;
        
        self.topRefreshView = [[DJRefreshView alloc] initWithFrame:CGRectMake(0, -kDJPulltoRefreshDistance, frame.size.width, kDJPulltoRefreshDistance)];
        [self addSubview:self.topRefreshView];
        
        self.bottomRefreshView = [DJRefreshView new];
        self.bottomRefreshView.dotColor = DJCommonStyle.ColorB5;
        self.bottomRefreshView.hidden = YES;
        DebugLayer(self, 1, [UIColor greenColor].CGColor);
    }
    return self;
}

-(void)setCustomMoreView:(UIView *)customMoreView{
    [_customMoreView removeFromSuperview];
    _customMoreView = customMoreView;
}

-(void)setScrollView:(UIScrollView *)scrollView{
    _scrollView = scrollView;
    _scrollView.frame = self.bounds;
    if (_scrollView.contentInset.bottom < kDJRefreshScrollViewBottomMargin) {
        _scrollView.contentInset = UIEdgeInsetsMake(_scrollView.contentInset.top, _scrollView.contentInset.left, kDJRefreshScrollViewBottomMargin, _scrollView.contentInset.right);
    }
    [self addSubview:scrollView];
}

-(void)setFrame:(CGRect)frame{
    if (frame.origin.x == self.frame.origin.x && frame.origin.y == self.frame.origin.y && frame.size.width == self.frame.size.width && frame.size.height == self.frame.size.height) {
        return;
    }
    
    [super setFrame:frame];
    _scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self resetTopRefreshView];
    self.topRefreshView.frame = CGRectMake(0, -kDJPulltoRefreshDistance, frame.size.width, kDJPulltoRefreshDistance);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    [self resetTopRefreshView];
    self.topRefreshView.frame = CGRectMake(0, -kDJPulltoRefreshDistance, self.frame.size.width, kDJPulltoRefreshDistance);
}

-(void)showLoadMoreInfo:(BOOL)show{
    if (show) {
        [self.scrollView addSubview:_customMoreView];
        _customMoreView.frame = CGRectMake(self.scrollView.frame.size.width / 2 - _customMoreView.frame.size.width / 2,  self.scrollView.contentSize.height - 25 + kDJPulltoRefreshDistance / 2 - _customMoreView.frame.size.height / 2, _customMoreView.frame.size.width, _customMoreView.frame.size.height);
    }else{
        [self.customMoreView removeFromSuperview];
    }
}

-(void)setIsLoadingMore:(BOOL)isLoadingMore{
    if (_isLoadingMore == isLoadingMore) {
        return;
    }
    _isLoadingMore = isLoadingMore;
    self.bottomRefreshView.hidden = YES;
    if (isLoadingMore) {
        self.bottomRefreshView.hidden = NO;
        [self.scrollView addSubview:self.bottomRefreshView];
        self.bottomRefreshView.frame = CGRectMake(0, self.scrollView.contentSize.height - 25, self.scrollView.frame.size.width, kDJPulltoRefreshDistance);
        if (_customMoreView) {
            _customMoreView.frame = CGRectMake(self.bottomRefreshView.frame.size.width / 2 - _customMoreView.frame.size.width / 2, self.bottomRefreshView.frame.size.height / 2 - _customMoreView.frame.size.height /2, _customMoreView.frame.size.width, _customMoreView.frame.size.height);
        }
        [self.bottomRefreshView startLoadingAnimation];
    }else{
        [self.bottomRefreshView removeFromSuperview];
    }
}

-(void)resetTopRefreshView{
    [self.topRefreshView resetAnimation];
    [self.topRefreshView resetTransform];
}

-(void)setIsPullLoading:(BOOL)isPullLoading{
    __weak DJRefreshContainerView *weakSelf = self;
    if (_isPullLoading == isPullLoading)
    {
        return;
    }
    
    self.animating = YES;
    _isPullLoading = isPullLoading;
    if (isPullLoading == NO)
    {
        [self.topRefreshView fadeAnimation:^(){
            weakSelf.topRefreshView.transform = CGAffineTransformIdentity;
            [weakSelf resetTopRefreshView];
            [weakSelf.scrollView.layer removeAllAnimations];
            if (weakSelf.bounce)
            {
                [weakSelf.scrollView moveFrom:CGPointMake(0, weakSelf.scrollView.frame.origin.y) to:CGPointMake(0, - 7) time:0.2 completion:^(){
                    [weakSelf.scrollView moveFrom:CGPointMake(0, weakSelf.scrollView.frame.origin.y) to:CGPointMake(0, 7) time:0.2 completion:^(){
                        [weakSelf.scrollView moveFrom:CGPointMake(0, weakSelf.scrollView.frame.origin.y) to:CGPointMake(0, 0) time:0.2 completion:^(){
                            weakSelf.animating = NO;
                            
                        }];
                    }];
                }];
            }else
            {
                [weakSelf.scrollView moveFrom:CGPointMake(0, weakSelf.scrollView.frame.origin.y) to:CGPointMake(0, 0) time:0.2 completion:^(){
                    weakSelf.animating = NO;
                }];
            }
        }];
    }else
    {
        self.scrollView.bounces = NO;
        self.scrollView.contentOffset = CGPointZero;
        [self.scrollView.layer removeAllAnimations];
        
        [self.scrollView moveFrom:CGPointMake(0, self.scrollView.frame.origin.y) to:CGPointMake(0, kDJPulltoRefreshDistance) time:0.2 completion:^(){
            weakSelf.scrollView.bounces = YES;
            weakSelf.animating = NO;
            weakSelf.topRefreshView.transform = CGAffineTransformMakeTranslation(0, kDJPulltoRefreshDistance);
            [weakSelf.topRefreshView startLoadingAnimation];
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isPullLoading || self.isLoadingMore || self.animating)
    {
        return;
    }
    
    if(scrollView.contentOffset.y >= 0)
    {
        return;
    }
    
    float ty;
    if (scrollView.contentOffset.y > -kDJPulltoRefreshDistance)
    {
        ty = - scrollView.contentOffset.y;
    }else
    {
        ty = kDJPulltoRefreshDistance;
    }
    self.topRefreshView.transform = CGAffineTransformMakeTranslation(0, ty);
    
    float dotDis = kDJRefreshDotRadius + kDJDotSpacing;
    if (scrollView.contentOffset.y >= -kDJPulltoRefreshDistance / 2)
    {
        [self.topRefreshView zeroScaleDots];
    }
    else if (scrollView.contentOffset.y > -kDJPulltoRefreshDistance + 10)
    {
        float scale = MIN(1 - (kDJPulltoRefreshDistance - 10 + scrollView.contentOffset.y) / (kDJPulltoRefreshDistance / 2 - 10), 1);
        //  NSLog(@"scale is %f offset %f", scale, scrollView.contentOffset.y);
        self.topRefreshView.redDot1.transform = CGAffineTransformMakeScale(0, 0);
        self.topRefreshView.redDot2.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        self.topRefreshView.redDot3.transform = CGAffineTransformMakeScale(0, 0);
    }
    else if (scrollView.contentOffset.y > - kDJPulltoRefreshDistance)
    {
        float dotTx = dotDis * (10 - kDJPulltoRefreshDistance - scrollView.contentOffset.y) / 10;
        self.topRefreshView.redDot1.transform = CGAffineTransformMakeTranslation(dotDis - dotTx, 0);
        self.topRefreshView.redDot2.transform = CGAffineTransformIdentity;
        self.topRefreshView.redDot3.transform = CGAffineTransformMakeTranslation(-dotDis + dotTx, 0);
    }
    else if(scrollView.contentOffset.y <= - kDJPulltoRefreshDistance)
    {
        [self.topRefreshView resetTransform];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y < - kDJPulltoRefreshDistance && !self.isPullLoading) {
        scrollView.frame = CGRectMake(0, -scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height);
        scrollView.bounces = NO;
        scrollView.contentOffset = CGPointZero;
        
        [self.scrollView.layer removeAllAnimations];
        __weak DJRefreshContainerView *weakSelf = self;
        self.animating = YES;
        [scrollView moveFrom:CGPointMake(0, scrollView.frame.origin.y) to:CGPointMake(0, kDJPulltoRefreshDistance - 4) time:0.2 completion:^(){
            [scrollView moveFrom:CGPointMake(0, scrollView.frame.origin.y) to:CGPointMake(0, kDJPulltoRefreshDistance + 3) time:0.2 completion:^(){
                [weakSelf.scrollView moveFrom:CGPointMake(0, weakSelf.scrollView.frame.origin.y) to:CGPointMake(0, kDJPulltoRefreshDistance) time:0.2 completion:^(){
                    weakSelf.scrollView.bounces = YES;
                    [weakSelf.topRefreshView startLoadingAnimation];
                    self.animating = NO;
                    if ([weakSelf.delegate respondsToSelector:@selector(refreshContainerViewPullLoading:)]) {
                        [weakSelf.delegate refreshContainerViewPullLoading:weakSelf];
                    }
                }];
            }];
        }];
    }
}


@end
