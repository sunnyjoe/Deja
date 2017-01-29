//
//  DJSortSlideView.m
//  DejaFashion
//
//  Created by Kevin Lin on 20/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJSortSlideView.h"
#import "MOTableCellBuilder.h"
#import "DejaFashion-swift.h"


@interface DJSortSlideView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentCellIndex;

@end

@implementation DJSortSlideView

-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorColor = [UIColor colorFromHexString:@"e4e4e4"];
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.showsVerticalScrollIndicator = YES;
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            self.tableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        [self addSubview:self.tableView];
    }
    return self;
}

-(void)setCellSortIds:(NSArray *)cellSortIds{
    _cellSortIds = cellSortIds;
    self.sortId = [self.cellSortIds[0] intValue];
}

-(void)setCellTitles:(NSArray *)cellTitles{
    _cellTitles = cellTitles;
    self.sortName = self.cellTitles[0];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.contentHeight);
    [self.tableView reloadData];
}

-(void)setContentHeight:(float)contentHeight{
    _contentHeight = contentHeight;
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, contentHeight);
    [self.tableView reloadData];
}

- (void)selectWithSortId:(NSInteger)sortId
{
    long index = [self.cellSortIds indexOfObject:@(sortId)];
    if (index == NSNotFound) {
        [self selectWithIndex:0];
        return;
    }
    [self selectWithIndex:index];
}

- (void)selectWithIndex:(long)index
{
    self.currentCellIndex = index;
    self.sortId = [self.cellSortIds[index] intValue];
    self.sortName = self.cellTitles[index];
    [self.tableView reloadData];
}

- (void)show{
    [super show];
    
    float contentOffset = MAX((self.currentCellIndex - 2) * kDJSortSlideViewCellHeight, 0);
    contentOffset = MIN((self.tableView.contentSize.height - self.tableView.frame.size.height), contentOffset);
    
    [self.tableView setContentOffset:CGPointMake(0, contentOffset)];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kDJSortSlideViewCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.textLabel.text = self.cellTitles[indexPath.row];
    cell.textLabel.textColor = [UIColor colorFromHexString:@"414141"];
    cell.textLabel.font = [DJFont helveticaFontOfSize:16];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorFromHexString:@"f9f9f9"];
    cell.indentationLevel = 1;
    cell.indentationWidth = self.leftPadding;
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([self.cellSortIds[indexPath.row] intValue] == self.sortId) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SelectedIcon"]];
    }
    else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectWithIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(sortSlideViewDidUpdateSortId:)]) {
        [((id<DJSortSlideViewDelegate>)self.delegate) sortSlideViewDidUpdateSortId:self];
    }
}

@end
