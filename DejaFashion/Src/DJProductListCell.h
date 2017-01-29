//
//  DJProductListCell.h
//  DejaFashion
//
//  Created by Kevin Lin on 2/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
 
@class Clothes;


@interface DJProductListCell : UITableViewCell

@property (nonatomic, strong) Clothes * product;
 
@end
