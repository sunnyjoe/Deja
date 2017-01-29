//
//  MOTableCellBuilder.h
//  Mozat
//
//  Created by Kevin Lin on 14/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOTableCellBuilder : NSObject

@property (nonatomic, copy) UITableViewCell* (^builder)(UITableView *, NSIndexPath *indexPath);
@property (nonatomic, copy) BOOL (^action)(UITableView *, NSIndexPath *indexPath);
@property (nonatomic, assign) float height;

@end
