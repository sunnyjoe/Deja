//
//  DJModelView.h
//  DejaFasion
//
//  Created by Sun lin on 14/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//


#define kDJModelViewHeight3x      1400
#define kDJModelViewWidth3x       860


#import "DJBasicBodyView.h"
@class DJModelView;
@class Clothes;


@protocol DJModelViewDelegate <NSObject>
@optional
-(void)modelView:(DJModelView *)modelView didClickProductDetail:(Clothes *)product;
-(void)modelView:(DJModelView *)modelView didClickTakeOff:(Clothes *)product;
@end

@interface DJModelView : DJBasicBodyView

@property(nonatomic, weak) id<DJModelViewDelegate> delegate;

@property(nonatomic, assign) BOOL canDisplayTuckButton;
@property(nonatomic, assign) BOOL shouldWearBasicSuntop;
@property(nonatomic, assign) BOOL shouldWearBasicPants;
@property(nonatomic, assign) BOOL wearedShoes;
@property(nonatomic, assign) BOOL tuck; // default is true
@property(nonatomic, strong) Clothes *mustTryClothes;

-(void)refreshModelWithClothes:(NSArray *)clothes;

-(BOOL)isNeatlyDressedWithAlert;
-(BOOL)removeMenuViewIfDisplay;
@end
