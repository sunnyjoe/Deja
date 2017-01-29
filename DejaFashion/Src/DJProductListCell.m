//
//  DJProductListCell.m
//  DejaFashion
//
//  Created by Kevin Lin on 2/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJProductListCell.h"
#import "DJLabel.h"
#import "DJDefinedSize.h"
#import "Dejafashion-swift.h"

@interface DJProductListCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *brandNameLabel;
@property (nonatomic, strong) DJLabel *priceLabel;
@property (nonatomic, strong) UIView *borderView;

@end

@implementation DJProductListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    return self;
}


-(void)setProduct:(Clothes *)product{
    _product = product;
    
    [self.iconView sd_setImageWithURLStr:_product.thumbUrl];
    self.brandNameLabel.text = _product.brandName;
    self.nameLabel.text = _product.name;
    self.priceLabel.text = [DJStringUtil stringFromPrice:(_product.curentPrice.floatValue / 100)   currencyCode:_product.currency];
}

- (void)buildUI
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    self.iconView = [UIImageView new];
    self.iconView.userInteractionEnabled = YES;
    self.iconView.layer.borderColor = [UIColor colorFromHexString:@"e4e4e4"].CGColor;
    self.iconView.layer.borderWidth = 0.5;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.iconView];
    
    self.nameLabel = [UILabel new];
    self.nameLabel.textColor = [UIColor colorFromHexString:@"262729"];
    self.nameLabel.font = [DJFont helveticaFontOfSize:15];
    self.nameLabel.numberOfLines = 2;
    [self.contentView addSubview:self.nameLabel];
    
    self.brandNameLabel = [UILabel new];
    self.brandNameLabel.textColor = [UIColor colorFromHexString:@"262729"];
    self.brandNameLabel.font = [DJFont helveticaFontOfSize:14];
    [self.contentView addSubview:self.brandNameLabel];
    
    self.priceLabel = [DJLabel new];
    self.priceLabel.textColor = [UIColor colorFromHexString:@"262729"];
    self.priceLabel.font = [DJFont helveticaFontOfSize:13];
    [self.contentView addSubview:self.priceLabel];
    
    
    self.borderView = [UIView new];
    self.borderView.backgroundColor = [UIColor colorFromHexString:@"cecece"];
    [self addSubview:self.borderView];
}
 

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize size = self.contentView.frame.size;
    
    self.borderView.frame = CGRectMake(0, size.height - 0.5,size.width, 0.5);

    self.iconView.frame = CGRectMake(23, size.height / 2 - 36, 63, 72);
    
    float ox = CGRectGetMaxX(_iconView.frame) + 11;
    float textWidth = self.contentView.frame.size.width - ox - 23;
    
    self.nameLabel.frame = CGRectMake(ox, self.iconView.frame.origin.y, textWidth, 20);
    self.brandNameLabel.frame = CGRectMake(ox, self.iconView.frame.origin.y + 25, textWidth, 20);
    self.priceLabel.frame = CGRectMake(ox, self.iconView.frame.origin.y + 51, textWidth, 18);
}

//- (void)iconDidTap
//{
//    if ([self.delegate respondsToSelector:@selector(productListCellDidClick:product:)]) {
//        [self.delegate productListCellDidClick:self product:_product];
//    }
//}


@end