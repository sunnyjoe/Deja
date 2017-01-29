//
//  DJMultiProductsMenuViewDelegate.m
//  DejaFashion
//
//  Created by Sun lin on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJMultiProductsMenuView.h"
#import "DJCabinetCollectionCell.h"
#import "DejaFashion-swift.h"

@interface DJMultiProductsMenuView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property (atomic,strong) NSArray *products;

@end

@implementation DJMultiProductsMenuView

- (instancetype)initWithFrame:(CGRect)frame products:(NSArray *)products arrowDirection:(DJProductMenuViewArrowDirection)direction
{
    self = [super initWithFrame:frame withTitle:MOLocalizedString(@"ALL ITEMS", @"") menuWidth:products.count * kDJMultiProductMenuCellWidth arrowDirection:direction];
    if(self)
    {
        self.products = products;
        UICollectionViewFlowLayout *collectionViewLayout = [UICollectionViewFlowLayout new];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 , [super menuListY], products.count * kDJMultiProductMenuCellWidth, kDJMultiProductMenuCellWidth) collectionViewLayout:collectionViewLayout];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[DJCabinetCollectionCell class] forCellWithReuseIdentifier:kDJCabinetCollectionViewCellId];
        [self addSubview:self.collectionView];
        
        DebugLayer(self.collectionView, 1.0, [UIColor redColor].CGColor);
    }
    return self;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.products.count;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DJCabinetCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDJCabinetCollectionViewCellId forIndexPath:indexPath];
    Clothes *ptd = [self.products objectAtIndex:indexPath.row];
    [cell setImageUrl:ptd.thumbUrl productColor:ptd.thumbColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(productsMenuView:didSelectProduct:)])
    {
        Clothes *pdt = [self.products objectAtIndex:indexPath.row];
        [self.delegate productsMenuView:self didSelectProduct:pdt];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float size = self.collectionView.bounds.size.height;
    return CGSizeMake(size, size);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


@end
