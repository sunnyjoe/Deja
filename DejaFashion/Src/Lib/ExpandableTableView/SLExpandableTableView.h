//
//  SLExpandableTableView.h
//  iGithub
//
//  Created by me on 11.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLExpandableTableView;


@protocol SLExpandableTableViewDatasource <UITableViewDataSource>
@end



@protocol SLExpandableTableViewDelegate <UITableViewDelegate>
@optional
- (void)tableView:(SLExpandableTableView *)tableView didExpandSection:(NSUInteger)section animated:(BOOL)animated;
- (void)tableView:(SLExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated;

@end



@interface SLExpandableTableView : UITableView <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) CGFloat bottomPadding;//default 61
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) BOOL singleExpend;//only one section expanded at a time
@property (nonatomic, strong) NSArray *headerVariedSection;
@property (nonatomic, readonly, weak) id<SLExpandableTableViewDelegate> myDelegate;
@property (nonatomic, readonly, weak) id<SLExpandableTableViewDatasource> myDataSource;

- (BOOL)isSectionExpanded:(NSInteger)section;
- (void)didClickHeaderView:(NSInteger)section;
- (void)collapseSection:(NSInteger)section animated:(BOOL)animiated;
@end
