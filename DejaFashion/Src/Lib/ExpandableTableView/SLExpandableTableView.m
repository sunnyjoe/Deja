//
//  SLExpandableTableView.m
//  iGithub
//
//  Created by me on 11.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "SLExpandableTableView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static BOOL protocol_containsSelector(Protocol *protocol, SEL selector)
{
    return protocol_getMethodDescription(protocol, selector, YES, YES).name != NULL || protocol_getMethodDescription(protocol, selector, NO, YES).name != NULL;
}

@interface SLExpandableTableView ()
@property (nonatomic, assign) BOOL inChanging;
@property (nonatomic, strong) NSMutableArray * expandedSections;
@end


@implementation SLExpandableTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.singleExpend = true;
        self.expandedSections = [NSMutableArray new];
        self.inChanging = false;
        self.headerHeight = 75;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)setDelegate:(id<SLExpandableTableViewDelegate>)delegate {
    _myDelegate = delegate;
    [super setDelegate:self];
}

- (void)setDataSource:(id<SLExpandableTableViewDatasource>)dataSource {
    _myDataSource = dataSource;
    [super setDataSource:self];
}


- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (protocol_containsSelector(@protocol(UITableViewDataSource), aSelector)) {
        return [super respondsToSelector:aSelector] || [_myDataSource respondsToSelector:aSelector];
    } else if (protocol_containsSelector(@protocol(UITableViewDelegate), aSelector)) {
        return [super respondsToSelector:aSelector] || [_myDelegate respondsToSelector:aSelector];
    }
    
    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (protocol_containsSelector(@protocol(UITableViewDataSource), aSelector)) {
        return _myDataSource;
    } else if (protocol_containsSelector(@protocol(UITableViewDelegate), aSelector)) {
        return _myDelegate;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

-(void)updateContentInset:(NSInteger)section{
    NSInteger cnt = [self.myDataSource numberOfSectionsInTableView:self];
    float height = 0;
    for (NSInteger i = section; i < cnt; i ++) {
        height += [self.myDelegate tableView:self heightForHeaderInSection:i];
    }
    if ([self.myDataSource tableView:self numberOfRowsInSection:section] == 0){
        return;
    }
    height += [self.myDelegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    float result = self.frame.size.height - height;
    if (result < self.bottomPadding){
        result = self.bottomPadding;
    }
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, result, self.contentInset.right);
}

#pragma mark - instance methods
- (void)expandSection:(NSInteger)section completion:(void (^)(void))completion{
    if (![self isValidSection:section]){
        return;
    }
    if ([self.expandedSections containsObject:@(section)]) {
        return;
    }
    
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.frame.size.height, self.contentInset.right);
    float delay = 0.35;
    if (self.contentOffset.y < 10 && section == 0) {
        delay = 0;
        [self setContentOffset:CGPointMake(0, self.headerHeight * section) animated:false];
    }else{
        [self setContentOffset:CGPointMake(0, self.headerHeight * section) animated:true];
    }
    [self.expandedSections addObject:@(section)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self beginUpdates];
        NSMutableArray *insertArray = [NSMutableArray array];
        for (int i = 0; i < [self.myDataSource tableView:self numberOfRowsInSection:section]; i++) {
            [insertArray addObject:[NSIndexPath indexPathForRow:i inSection:section] ];
        }
        [self insertRowsAtIndexPaths:insertArray withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadData];
            [self updateContentInset:section];
            
            if (completion) {
                completion();
            }
        });
    });
}

- (void)collapseSection:(NSInteger)section animated:(BOOL)animiated{
    if (![self isValidSection:section]){
        return;
    }
    
    if (![self.expandedSections containsObject:@(section)]) {
        return;
    }
    
    [self.expandedSections removeObject:@(section)];
    
    if (animiated) {
        NSInteger newRowCount = [self.myDataSource tableView:self numberOfRowsInSection:section];
        [self beginUpdates];
        NSMutableArray *deleteArray = [NSMutableArray array];
        for (int i = 0; i < newRowCount; i++) {
            [deleteArray addObject:[NSIndexPath indexPathForRow:i inSection:section] ];
        }
        [self deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationNone];
        [self endUpdates];
    }
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

-(BOOL)isValidSection:(NSInteger)section{
    if (section >= 0 && section < [self.myDataSource numberOfSectionsInTableView:self]){
        return true;
    }
    return false;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
}


#pragma mark - UITableViewDelegate
-(void)didClickHeaderView:(NSInteger)section
{
    if (![self isValidSection:section]){
        return;
    }
    if (self.inChanging) {
        return;
    }
    
    self.inChanging = true;
    if ([self.expandedSections containsObject:@(section)]) {
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.frame.size.height, self.contentInset.right);
        [self setContentOffset:CGPointMake(0, self.headerHeight * section) animated:false];
        [self collapseSection:section animated:true];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setContentOffset:CGPointZero animated:true];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.contentInset = UIEdgeInsetsMake(0, 0, self.bottomPadding, 0);
                self.inChanging = false;
            });
        });
    } else {
        BOOL collapseFirst = false;
        if (self.singleExpend) {
            if (self.expandedSections.count > 0){
                NSInteger closeOne = [self.expandedSections[0] integerValue];
                collapseFirst = true;
                self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.frame.size.height, self.contentInset.right);
                [self setContentOffset:CGPointMake(0, self.headerHeight * closeOne) animated:false];
                [self collapseSection:closeOne animated:false];
            }
        }
        
        [self expandSection:section completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.inChanging = false;
            });
        }];
    }
}

-(BOOL)isSectionExpanded:(NSInteger)section{
    return [self.expandedSections containsObject:@(section)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.myDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.myDelegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] ];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.expandedSections containsObject:@(section)]) {
        return [self.myDataSource tableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.myDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

@end
