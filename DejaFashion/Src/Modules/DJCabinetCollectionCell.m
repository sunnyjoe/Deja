//
//  DJCabinetCollectionCell.m
//  DejaFashion
//
//  Created by Sun lin on 24/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJCabinetCollectionCell.h"

@interface DJCabinetCollectionCell()


@property(nonatomic, strong) UIView *maskView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) NSString *imageUrl;

@end


@implementation DJCabinetCollectionCell

@synthesize image = _image;;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [UIImageView new];
        self.imageView.frame = self.bounds;
        
        self.containerView = [UIView new];
        self.containerView.frame = self.bounds;
        self.containerView.contentMode = UIViewContentModeTop;
        self.containerView.layer.borderColor = [UIColor colorFromHexString:@"e4e4e4"].CGColor;
        self.containerView.layer.borderWidth = 0.7;
        [self.containerView addSubview:self.imageView];
        [self.contentView addSubview:self.containerView];
        DebugLayer(self.imageView, 1.0, [UIColor greenColor].CGColor);
        
        self.maskView = [UIView new];
        self.maskView.frame = self.bounds;
        self.maskView.backgroundColor = [UIColor whiteColor];
        self.maskView.alpha = 0.0;
        [self.contentView addSubview:self.maskView];
    }
    return self;
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = _image;
    self.imageView.frame = self.bounds;
}

-(void)setImageUrl:(NSString *)imageUrl productColor:(NSString *)colorValue
{
    self.imageUrl = imageUrl;
//    if(colorValue.length > 0)
//    {
//        self.imageView.image = [UIImage imageWithColor:[UIColor colorFromHexString:colorValue]];
//    }
//    else
//    {
//        self.imageView.image = [UIImage imageNamed:@"LoadingLogo"];
//    }
//    [self.imageView setImageWithURL:[NSURL URLWithString:self.imageUrl]];
    if(colorValue.length > 0)
    {
        UIColor *color = [UIColor colorFromHexString:colorValue];
        UIImage *image =  [UIImage imageWithColor:color];
        self.imageView.image = image;
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }
    else
    {
        self.imageView.image = [UIImage imageNamed:@"LoadingLogo"];
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    __weak DJCabinetCollectionCell *weakSelf = self;
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       if(!request && !response)
                                       {
                                           //image in cache
                                           weakSelf.imageView.alpha = 1.0;
                                           weakSelf.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                           weakSelf.imageView.image = image;
                                       }
                                       else
                                       {
                                           weakSelf.imageView.alpha = 0.0;
                                           weakSelf.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                           weakSelf.imageView.image = image;
                                           [UIView animateWithDuration:0.2 animations:^{
                                               weakSelf.imageView.alpha = 1.0;
                                           } completion:^(BOOL finished) {
                                           }];
                                       }
                                   } failure:nil];
    
}

//-(void)setImageUrl:(NSString *)imageUrl imageWidth:(UInt32)imgW imageHeight:(UInt32)imgH
//{
//    self.imageUrl = imageUrl;
//    [self.imageView setImageWithURL:[NSURL URLWithString:self.imageUrl]];
//    if(imageUrl && imgW > 0 && imgH > 0)
//    {
//        CGRect frame = self.imageView.frame;
//        frame.size.height = imgH * self.bounds.size.width / imgW;
//        if(imgW > imgH)
//        {
//            frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
//        }
//        self.imageView.frame = frame;
//    }
//    else
//    {
//        self.imageView.frame = self.bounds;
//    }
//}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.maskView.alpha = 0.6;
    }
    else
    {
        self.maskView.alpha = 0.0;
    }
}
@end
