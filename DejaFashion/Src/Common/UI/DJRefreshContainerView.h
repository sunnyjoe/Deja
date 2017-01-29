//
//  DJRefreshContainerView.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 8/10/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DJRefreshContainerView;

@protocol DJRefreshContainerViewDelegate <NSObject>

-(void)refreshContainerViewPullLoading:(DJRefreshContainerView *)pullRefreshView;

@end

@interface DJRefreshContainerView : UIView <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) id <DJRefreshContainerViewDelegate>delegate;
@property (nonatomic, assign) BOOL isPullLoading;
@property (nonatomic, assign) BOOL isLoadingMore; 
@property (nonatomic, assign) BOOL bounce;//Default is yes
@property (strong, nonatomic) UIView *customMoreView;

- (void)showLoadMoreInfo:(BOOL)show;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end
