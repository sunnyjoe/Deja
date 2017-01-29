//
//  DJProductFilterView.m
//  DejaFashion
//
//  Created by DanyChen on 28/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import "DJProductFilterView.h"
#import "DejaFashion-swift.h"

@interface DJProductFilterView()<DJRangeSilderViewDelegate>

@property (nonatomic, strong) NSMutableArray *saleContainerViewBtnArray;
@property (nonatomic, strong) DJRangeSilderView *rangeSilderView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, assign) DJProductSearchStatusType lastSearchStatus;
@property (nonatomic, assign) NSInteger lastLowerPrice;
@property (nonatomic, assign) NSInteger lastHigherPrice;

@end


@implementation DJProductFilterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    self.backgroundColor = [DJCommonStyle backgroundColorWithAlpha:0.75f];
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 260)];
    self.contentScrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentScrollView];
    
    [self addTapGestureTarget:self action:@selector(emptyAreaDidClick:)];
    [self.contentScrollView addTapGestureTarget:self action:@selector(consumeTap)];
    float YHeight = 0;
    BOOL addSeperator = NO;
    {
        {
            UIView *saleContainerView = [UIView new];
            saleContainerView.backgroundColor = [UIColor whiteColor];
            [self.contentScrollView addSubview:saleContainerView];
            saleContainerView.frame = CGRectMake(0, YHeight, self.frame.size.width, 56);
            
            addSeperator = YES;
            
            self.saleContainerViewBtnArray = [NSMutableArray new];
            NSArray *names = [NSArray arrayWithObjects:MOLocalizedString(@"All", @""), MOLocalizedString(@"Sale", @""), MOLocalizedString(@"New Arrivals", @""), nil];
            float XWidth = 20;
            NSInteger cnt = 0;
            for (NSString *name in names) {
                UIButton *clickBtn = [[UIButton alloc] initWithFrame:CGRectMake(XWidth, saleContainerView.frame.size.height / 2 - 6, 12, 12)];
                clickBtn.tag = cnt;
                clickBtn.contentMode = UIViewContentModeCenter;
                if(cnt == self.searchStatus){
                    [clickBtn setImage:[UIImage imageNamed:@"RadioIconPressed"] forState:UIControlStateNormal];
                }else{
                    [clickBtn setImage:[UIImage imageNamed:@"RadioIcon"] forState:UIControlStateNormal];
                }
                [self.saleContainerViewBtnArray addObject:clickBtn];
                [clickBtn addTarget:self action:@selector(saleDidClick:) forControlEvents:UIControlEventTouchUpInside];
                [saleContainerView addSubview:clickBtn];
                
                UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
                nameLable.textAlignment = NSTextAlignmentCenter;
                nameLable.text = name;
                nameLable.tag = cnt;
                nameLable.font = [DJFont contentFontOfSize:16];
                nameLable.textColor = [UIColor colorFromHexString:@"414141"];
                nameLable.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saleDidClick:)];
                tapG.property = nameLable;
                [nameLable addGestureRecognizer:tapG];
                [saleContainerView addSubview:nameLable];
                
                [nameLable sizeToFit];
                nameLable.frame = CGRectMake(CGRectGetMaxX(clickBtn.frame), saleContainerView.frame.size.height / 2 - nameLable.frame.size.height / 2, nameLable.frame.size.width + 20, nameLable.frame.size.height);
                XWidth = CGRectGetMaxX(nameLable.frame) + 43;
                
                cnt ++;
            }
            
            YHeight += saleContainerView.frame.size.height;
        }
    }
    
    {
        if (addSeperator) {
            UIView *seperatorView = [UIView new];
            seperatorView.backgroundColor = [UIColor whiteColor];
            [self.contentScrollView addSubview:seperatorView];
            seperatorView.layer.borderColor = [UIColor colorFromHexString:@"eaeaea"].CGColor;
            seperatorView.layer.borderWidth = 1;
            seperatorView.frame = CGRectMake(20, YHeight - 1, self.frame.size.width - 40, 1);
            addSeperator = NO;
        }
        
        {
            UIView *priceContainerView = [UIView new];
            priceContainerView.backgroundColor = [UIColor whiteColor];
            [self.contentScrollView addSubview:priceContainerView];
            priceContainerView.frame = CGRectMake(0, YHeight, self.frame.size.width, 97);
            
            addSeperator = YES;
            
            UILabel *priceLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, 150, 10)];
            priceLable.textAlignment = NSTextAlignmentLeft;
            priceLable.text = MOLocalizedString(@"Price (S$)", @"");
            priceLable.font = [DJFont contentFontOfSize:16];
            priceLable.textColor = [UIColor colorFromHexString:@"414141"];
            [priceContainerView addSubview:priceLable];
            [priceLable sizeToFit];
            
            self.priceLabel = [UILabel new];
            [priceContainerView addSubview:self.priceLabel];
            self.priceLabel.textAlignment = NSTextAlignmentLeft;
            self.priceLabel.font = [DJFont contentFontOfSize:14];
            self.priceLabel.textColor = [UIColor colorFromHexString:@"f81f34"];
            [self priceLabelSetFrame:MOLocalizedString(@"All Prices", @"")];
            
            self.rangeSilderView = [[DJRangeSilderView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(priceLable.frame) + 6, priceContainerView.frame.size.width - 20, priceContainerView.frame.size.height - CGRectGetMaxY(priceLable.frame))];
            self.rangeSilderView.rangeValues = [NSArray arrayWithObjects:@(0),@(30),@(50),@(80),@(120),@(200), nil];
            self.rangeSilderView.delegate = self;
            [priceContainerView addSubview:self.rangeSilderView];
            YHeight += priceContainerView.frame.size.height;
        }
    }
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, YHeight + 30, self.frame.size.width, 52.5)];
    [self.contentScrollView addSubview:self.footerView];
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.footerView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
//    self.footerView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.05].CGColor;
//    self.footerView.layer.shadowOpacity = 0.8;
//    self.footerView.layer.shadowRadius = 1.5;
    
    float btnWidth = (self.frame.size.width - 46 - 15) / 2;

    DJButton *resetBtn = [DJButton new];
    [resetBtn blackTitleWhiteStyle];
    [resetBtn setTitle:MOLocalizedString(@"Reset", @"") forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetBtnDidTap) forControlEvents:UIControlEventTouchUpInside];
    [resetBtn sizeToFit];
    [self.footerView addSubview:resetBtn];
    resetBtn.frame = CGRectMake(23, self.footerView.frame.size.height / 2 -  16.5, btnWidth, 33);
    
    DJButton *doneBtn = [DJButton new];
    [doneBtn whiteTitleBlackStyle];
    [doneBtn setTitle:MOLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneBtnDidTap) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn sizeToFit];
    [self.footerView addSubview:doneBtn];
    doneBtn.frame = CGRectMake(23 + btnWidth + 15, self.footerView.frame.size.height / 2 - 16.5, btnWidth, 33);
    
}

-(void)consumeTap {
    
}

-(void)emptyAreaDidClick: (UITapGestureRecognizer *)reg {
    [self.delegate productFilterBackgroundDidClick:self];
}

-(void)priceLabelSetFrame:(NSString *)text{
    self.priceLabel.text = text;
    [self.priceLabel sizeToFit];
    self.priceLabel.frame = CGRectMake(self.contentScrollView.frame.size.width - 20 - self.priceLabel.frame.size.width, 17, self.priceLabel.frame.size.width, self.priceLabel.frame.size.height);
}

-(void)saleDidClick:(id)sender{
    UIView *btnOrLabel;
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        btnOrLabel = (UIView *)((UITapGestureRecognizer *)sender).property;
    }else{
        btnOrLabel = (UIView *)sender;
    }
    
    for (UIButton *oneBtn in self.saleContainerViewBtnArray) {
        if (oneBtn.tag == btnOrLabel.tag) {
            [oneBtn setImage:[UIImage imageNamed:@"RadioIconPressed"] forState:UIControlStateNormal];
        }else{
            [oneBtn setImage:[UIImage imageNamed:@"RadioIcon"] forState:UIControlStateNormal];
        }
    }
    self.searchStatus = (DJProductSearchStatusType)btnOrLabel.tag;
}

-(void)priceLabelShouldChange{
    NSArray<NSNumber *> *rangeValues = self.rangeSilderView.rangeValues;
    if (rangeValues.count < 2) {
        return;
    }
    
    NSString *labelText;
    if (self.lowerPrice == ((NSNumber *)rangeValues[0]).integerValue && self.higherPrice == 0) {
        labelText = MOLocalizedString(@"ALL PRICES", @"");
    }else if(self.higherPrice == 0){
        labelText = [NSString stringWithFormat:@"Above S$%ld",(long)self.lowerPrice];
    }else if(self.lowerPrice == ((NSNumber *)rangeValues[0]).integerValue){
        labelText = [NSString stringWithFormat:@"Under S$%ld",(long)self.higherPrice];
    }else{
        labelText = [NSString stringWithFormat:@"S$%ld - S$%ld",(long)self.lowerPrice, (long)self.higherPrice];
    }
    [self priceLabelSetFrame:labelText];
}

#pragma mark DJRangeSilderViewDelegate
-(void)rangeValueDidChanged:(DJRangeSilderView *)rangeSliderView lowerValue:(CGFloat)lowerValue higherValue:(CGFloat)higherValue{
    self.lowerPrice = lowerValue;
    self.higherPrice = higherValue;
    [self priceLabelShouldChange];
}

- (void)doneBtnDidTap
{
    if ([self.delegate respondsToSelector:@selector(productFilterViewDone:)]) {
        [self.delegate productFilterViewDone:self];
    }
    self.lastSearchStatus = self.searchStatus;
    self.lastLowerPrice = self.lowerPrice;
    self.lastHigherPrice = self.higherPrice;
}

- (void)resetBtnDidTap
{
    for (UIButton *oneBtn in self.saleContainerViewBtnArray) {
        if (oneBtn.tag == DJProductSearchStatusAll) {
            [oneBtn setImage:[UIImage imageNamed:@"RadioIconPressed"] forState:UIControlStateNormal];
        }else{
            [oneBtn setImage:[UIImage imageNamed:@"RadioIcon"] forState:UIControlStateNormal];
        }
    }
    self.searchStatus = DJProductSearchStatusAll;
    
    NSArray<NSNumber *> *rangeValues = self.rangeSilderView.rangeValues;
    if (rangeValues.count > 1) {
        self.lowerPrice = rangeValues[0].integerValue;
        self.higherPrice = 0;
        [self priceLabelShouldChange];
    }
    [self.rangeSilderView resetSlider];
}

-(void)setHidden:(BOOL)hidden {
    if (!hidden) {
        for (UIButton *oneBtn in self.saleContainerViewBtnArray) {
            if (oneBtn.tag == self.lastSearchStatus) {
                [oneBtn setImage:[UIImage imageNamed:@"RadioIconPressed"] forState:UIControlStateNormal];
            }else{
                [oneBtn setImage:[UIImage imageNamed:@"RadioIcon"] forState:UIControlStateNormal];
            }
        }
        self.searchStatus = self.lastSearchStatus;
        self.higherPrice = self.lastHigherPrice;
        self.lowerPrice = self.lastLowerPrice;
        [self.rangeSilderView startPointsSlider:self.lastLowerPrice rightValue:self.lastHigherPrice];
        [self priceLabelShouldChange];

    }
    [super setHidden:hidden];
}

@end
