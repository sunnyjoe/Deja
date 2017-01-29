//
//  DJCabinetCollectionCell.h
//  DejaFashion
//
//  Created by Sun lin on 24/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDJCabinetCollectionViewCellId  @"kDJCabinetCollectionViewCellId"
#define kDJFaceChooseCollectionViewCellId @"kDJFaceChooseCollectionViewCellId"

@interface DJCabinetCollectionCell : UICollectionViewCell

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, strong) UIImageView *imageView;


//-(void)setImageUrl:(NSString *)imageUrl imageWidth:(UInt32)imgW imageHeight:(UInt32)imgH;
-(void)setImageUrl:(NSString *)imageUrl productColor:(NSString *)colorValue;
@end
