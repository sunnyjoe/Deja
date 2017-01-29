//
//  MOCollectionCellBuilder.h
//  DejaFashion
//
//  Created by Sun lin on 9/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOCollectionCellBuilder : NSObject
@property (nonatomic, copy) UIView* (^builder)(UICollectionViewCell *, NSIndexPath *indexPath);
@property (nonatomic, copy) BOOL (^action)(UICollectionView *, NSIndexPath *indexPath);

@end
