//
//  DJSingleProductMenuView.m
//  DejaFashion
//
//  Created by Sun lin on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJSingleProductMenuView.h"
#import "DJStringUtil.h"
#import "DejaFashion-swift.h"

@interface DJSingleProductMenuView()

@property (atomic,strong) Clothes *product;

@end

@implementation DJSingleProductMenuView
- (instancetype)initWithFrame:(CGRect)frame product:(Clothes *)product arrowDirection:(DJProductMenuViewArrowDirection)direction showTuckOption:(BOOL)showTuck tuckValue:(NSString *)tuckValue showTakeoff:(BOOL)showTakeoff showDetail:(BOOL)showDetail
{
    NSString *menuTitle = product.name;
    if ([DJConstants isDebug]) {
        menuTitle = [NSString stringWithFormat:@"(%@)%@", product.uniqueID, menuTitle];
    }
    
    self = [super initWithFrame:frame withTitle:menuTitle menuWidth:kDJSigleProductMenuWidth arrowDirection:direction];
    if(self)
    {
        self.product = product;
        
        float oY = [super menuListY];
        if (showTuck) {
            DJButton *tuckBtn = [[DJButton alloc] initWithFrame:CGRectMake(0, oY, kDJSigleProductMenuWidth, 31)];
            [[[tuckBtn withTitle:tuckValue] withFontHeletica:14] withTitleColor:[UIColor blackColor]];
            [tuckBtn addTarget:self action:@selector(tuckBtnDidTapped) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:tuckBtn];
            tuckBtn.contentMode = UIViewContentModeCenter;
            tuckBtn.backgroundColor = [UIColor whiteColor];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 30.5, kDJSigleProductMenuWidth, 0.5)];
            line.backgroundColor = [UIColor colorFromHexString:@"cecece"];
            [tuckBtn addSubview:line];
            oY += 31;
        }
        if (showTakeoff){
            DJButton *takeOffBtn = [[DJButton alloc] initWithFrame:CGRectMake(0, oY, kDJSigleProductMenuWidth, 31)];
            [[[takeOffBtn withTitle:MOLocalizedString(@"Take Off", @"")] withFontHeletica:14] withTitleColor:[UIColor blackColor]];
            [takeOffBtn addTarget:self action:@selector(takeOffBtnDidTapped) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:takeOffBtn];
            takeOffBtn.contentMode = UIViewContentModeCenter;
            takeOffBtn.backgroundColor = [UIColor whiteColor];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(takeOffBtn.frame), kDJSigleProductMenuWidth, 0.5)];
            line.backgroundColor = [UIColor colorFromHexString:@"cecece"];
            [self addSubview:line];
            oY += 31;
        }
        if (showDetail) {
            DJButton *detailBtn = [[DJButton alloc] initWithFrame:CGRectMake(0, oY, kDJSigleProductMenuWidth, 31)];
            detailBtn.backgroundColor = [UIColor whiteColor];
            detailBtn.contentMode = UIViewContentModeCenter;
            [[[detailBtn withTitle:MOLocalizedString(@"View Detail", @"")] withFontHeletica:14] withTitleColor:[UIColor blackColor]];
            [detailBtn addTarget:self action:@selector(detailBtnDidTapped) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:detailBtn];
        }
    }
    return self;
}

- (void)tuckBtnDidTapped{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickSingleProductMenuTuck:)])
    {
        [self.delegate didClickSingleProductMenuTuck:self.product];
    }
}

- (void)takeOffBtnDidTapped{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickSingleProductMenuTakeOff:)])
    {
        [self.delegate didClickSingleProductMenuTakeOff:self.product];
    }
}

- (void)detailBtnDidTapped{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickSingleProductMenuDetail:)])
    {
        [self.delegate didClickSingleProductMenuDetail:self.product];
    }
}


@end
