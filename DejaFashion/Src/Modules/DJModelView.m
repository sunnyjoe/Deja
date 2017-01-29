//
//  DJModelView.m
//  DejaFasion
//
//  Created by Sun lin on 14/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//
@import SDWebImage;

#import "DJFaceView.h"
#import "DJMultiProductsMenuView.h"
#import "DJSingleProductMenuView.h"
#import "DJConfigDataContainer.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DejaFashion-swift.h"


@interface DJModelView ()<DJMultiProductsMenuViewDelegate,DJSingleProductMenuViewDelegate>

@property (nonatomic, strong) DJMultiProductsMenuView *multiMenuView;
@property (nonatomic, strong) DJSingleProductMenuView *singleMenuView;

@property (nonatomic, strong) NSMutableArray *topSubCateIds;
@property (nonatomic, strong) NSMutableArray *bottomSubCateIds;
@property (nonatomic, strong) NSMutableArray *shoesSubCateIds;
@property (nonatomic, strong) NSMutableArray *tuckSubCateIds;
@property (nonatomic, strong) NSMutableArray *bagSubCateIds;

@property (nonatomic, strong) NSArray *currentProducts;
@property(nonatomic, assign) BOOL tuckable; //default is false


@end

@implementation DJModelView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.tuck = true;
        self.tuckable = false;
        [self removeMenuViewIfDisplay];
    }
    return self;
}

-(void)refreshModelWithClothes:(NSArray *)clothes
{
    [self.viewForReshape addSubview:self.glkView];
    @autoreleasepool {
        CALayer *renderLayer = [CALayer layer];
        renderLayer.frame = self.bounds;
        CGRect rect = renderLayer.frame;
        
        UInt64 time1 = [NSDate currentTimeMillis];
        [self.dejaModelLayer removeAllSubLayers];
        
        [self makeModelBasicLayer];
        
        CALayer *backLayer = [CALayer layer];
        backLayer.frame = rect;
        
        CALayer *tuckBackLayer = [CALayer layer];
        tuckBackLayer.frame = rect;
        
        CALayer *rightLayer = [CALayer layer];
        rightLayer.frame = rect;
        
        CALayer *headLayer = [CALayer layer];
        headLayer.frame = rect;
        
        CALayer *leftLayer = [CALayer layer];
        leftLayer.frame = rect;
        
        CALayer *frontLayer = [CALayer layer];
        frontLayer.frame = rect;
        
        self.shouldWearBasicSuntop = YES;
        self.shouldWearBasicPants = YES;
        self.wearedShoes = NO;
        
        BOOL shouldTuck = self.tuck;
        BOOL canTuckTop = NO;
        BOOL hasBottomItem = NO;
        
        NSArray *clothedForRender = [clothes copy];
        NSMutableDictionary *id2Layer = [NSMutableDictionary new];
        for (int i = 0; i < clothedForRender.count; i++)
        {
            Clothes *pdt  = [clothedForRender objectAtIndex:i];
            if([self isBottomItem:pdt])
            {
                hasBottomItem = YES;
            }
            if([self canTuckTop:pdt])
            {
                canTuckTop = YES;
                if(shouldTuck)
                {
                    [id2Layer setObject:@"425" forKey:pdt.uniqueID];
                }
                else
                {
                    [id2Layer setObject:pdt.layer forKey:pdt.uniqueID];
                }
            }
            else
            {
                [id2Layer setObject:pdt.layer forKey:pdt.uniqueID];
            }
        }
        
        self.tuckable = (canTuckTop && hasBottomItem);
        if(shouldTuck)
        {
            clothedForRender = [clothedForRender sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                Clothes *pdt1 = obj1;
                Clothes *pdt2 = obj2;
                NSArray *layers1 = [(NSString *)[id2Layer objectForKey:pdt1.uniqueID] componentsSeparatedByString:@","];
                NSArray *layers2 = [(NSString *)[id2Layer objectForKey:pdt2.uniqueID] componentsSeparatedByString:@","];
                
                int layer1 = ((NSNumber *)[layers1 objectAtIndex:0]).intValue;
                int layer2 = ((NSNumber *)[layers2 objectAtIndex:0]).intValue;
                if(layer1 > layer2)
                {
                    return NSOrderedDescending;
                }
                if(layer1 < layer2)
                {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
        }
        
        for(Clothes *pdt in clothedForRender)
        {
            //dresses = 3, tops = 1, skirts = 8, bottoms = 2, outwear = 7, jumpsuits = 9, shoes = 4, bags = 5, accessories = 6
            if([self isTopItem:pdt])
            {
                self.shouldWearBasicSuntop = NO;
            }
            if([self isBottomItem:pdt])
            {
                self.shouldWearBasicPants = NO;
            }
            if([self isShoes:pdt])
            {
                self.wearedShoes = YES;
            }
            
            WearableImage *back = pdt.backWearableImage;
            WearableImage *right= pdt.rightWearableImage;
            WearableImage *front= pdt.frontWearableImage;
            WearableImage *left= pdt.leftWearableImage;
            WearableImage *head= pdt.headWearableImage;
            if(back)
            {
                CALayer *subLayer = [self makeLayerWithWearableImage:back frame:back.rect isMask:false];
                
                if([self canTuckTop:pdt])
                {
                    [tuckBackLayer insertSublayer:subLayer atIndex:0];
                }
                else
                {
                    [backLayer insertSublayer:subLayer atIndex:0];
                }
            }
            
            if(right)
            {
                [self addWearableImage:right toLayer:rightLayer backLayerArray:nil faceOffsetY:0];
            }
            
            if(front)
            {
                if(shouldTuck && [self isBottomItem:pdt])
                {
                    [self addWearableImage:front toLayer:frontLayer backLayerArray:[NSArray arrayWithObjects:tuckBackLayer, nil] faceOffsetY:0];
                }
                else
                {
                    [self addWearableImage:front toLayer:frontLayer backLayerArray:nil faceOffsetY:0];
                }
            }
            
            if(left)
            {
                [self addWearableImage:left toLayer:leftLayer backLayerArray:nil faceOffsetY:0];
            }
            if(head)
            {
                int _headOffSetY = 0;
                if([self isGlasses:pdt])
                {
                    _headOffSetY = 20 * DJFaceScale;
                }
                
                [self addWearableImage:head toLayer:headLayer backLayerArray:[NSArray arrayWithObjects:self.frontHairLayer, self.backHairLayer, nil] faceOffsetY:_headOffSetY];
            }
        }
        
        if (self.shouldWearBasicSuntop) {
            self.basicSuntopLayer = [self makeBasicSuntopLayer];
        }
        
        if (self.shouldWearBasicPants) {
            self.basicPantsLayer = [self makeBasicPantsLayer];
        }
        
        [renderLayer addSublayer:backLayer];
        [renderLayer addSublayer:tuckBackLayer];
        [renderLayer addSublayer:self.backHairLayer];
        [renderLayer addSublayer:self.bodyRightLayer];
        [renderLayer addSublayer:rightLayer];
        [renderLayer addSublayer:self.bodyLayer];
        [renderLayer addSublayer:self.bodyBreastLayer];
        [renderLayer addSublayer:self.bodyLegLayer];
        if(self.shouldWearBasicSuntop)
        {
            [renderLayer addSublayer:self.basicSuntopLayer];
        }
        if(self.shouldWearBasicPants)
        {
            [renderLayer addSublayer:self.basicPantsLayer];
        }
        [renderLayer addSublayer:self.faceLayer];
        [renderLayer addSublayer:frontLayer];
        [renderLayer addSublayer:self.bodyLeftLayer];
        [renderLayer addSublayer:leftLayer];
        [renderLayer addSublayer:self.frontHairLayer];
        [renderLayer addSublayer:headLayer];
        
        [self.dejaModelLayer addSublayer:renderLayer];
        
        UInt64 time2 = [NSDate currentTimeMillis] - time1;
        [DJLog info:DJ_UI content:@"render deja model view duration = %d", time2];
        
        self.currentProducts = clothes;
    }
}


-(CALayer *)makeLayerWithImage:(UIImage *)inputImage frame:(CGRect)frame wearableInfo:(WearableImage *)wimage
{
    CGRect inputRect = [self imageFullRect];
    NSString *textureData = wimage.imageReshapeTexture;
    NSString *posData = wimage.imageReshapePosition;
    
    BOOL success = [self.glkView reshapeImageWith:inputImage imageRect:inputRect textureData:textureData positionData:posData];
    
    CALayer* subLayer = [CALayer layer];
    subLayer.contentsScale = 1.0;
    UIImage *image;
    if (success) {
        subLayer.frame = self.bounds;
        image = [self.glkView reshapedImage];
    }else{
        subLayer.frame = [self transformImageRectToView:inputRect];
        image = inputImage;
    }
    subLayer.contents = (id)[image CGImage];
    
    return subLayer;
}

-(CALayer *)makeLayerWithWearableImage:(WearableImage *)wimage frame:(CGRect)frame isMask:(BOOL)isMask
{
    BOOL success = false;
    UIImage *inputImage;
    CGRect inputRect;
    NSString *textureData;
    NSString *posData;
    
    if (isMask) {
        inputImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:wimage.maskUrl];
        inputRect = [self imageFullRect];
        textureData = wimage.maskReshapeTexture;
        posData = wimage.maskReshapePosition;
    }else{
        inputImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:wimage.imageUrl];
        inputRect = frame;
        textureData = wimage.imageReshapeTexture;
        posData = wimage.imageReshapePosition;
    }
    if ([[FittingRoomDataContainer sharedInstance] isDefaultBodyShape:self.bodyShape legShape:self.legShape]) {
        success = false;//no need to reshape
    }else{
        success = [self.glkView reshapeImageWith:inputImage imageRect:inputRect textureData:textureData positionData:posData];
    }
    
    CALayer* subLayer = [CALayer layer];
    subLayer.contentsScale = 1.0;
    UIImage *image;
    if (success) {
        subLayer.frame = self.bounds;
        image = [self.glkView reshapedImage];
    }else{
        subLayer.frame = [self transformImageRectToView:inputRect];
        image = inputImage;
    }
    subLayer.contents = (id)[image CGImage];
    
    return subLayer;
}

-(void)addWearableImage:(WearableImage *)wearableImage toLayer:(CALayer *)currentLayer backLayerArray:(NSArray *)backLayerArray faceOffsetY:(CGFloat)offsetY
{
    CGRect rect = wearableImage.rect;
    rect.origin.y += offsetY;
    
    if(wearableImage.maskUrl.length)
    {
        CALayer *maskLayer;
        if (currentLayer.contents || currentLayer.sublayers.count > 0 || backLayerArray.count > 0){
            maskLayer = [self makeLayerWithWearableImage:wearableImage frame:[self imageFullRect] isMask:true];
        }
        
        for (CALayer *backLayer in backLayerArray) {
            [backLayer setMask:maskLayer];
        }
        
        if (currentLayer.contents != nil || currentLayer.sublayers.count > 0) {
            [currentLayer setMask:maskLayer];
            
            UIImage *maskedImage = [currentLayer getImageFromLayer];
            CALayer *newLayer = [CALayer layer];
            newLayer.frame = currentLayer.bounds;
            newLayer.contents =  (__bridge id)(maskedImage.CGImage);
            [currentLayer setMask:nil];
            [currentLayer removeAllSubLayers];
            [currentLayer addSublayer:newLayer];
        }
    }
    
    CALayer *imageLayer = [self makeLayerWithWearableImage:wearableImage frame:rect isMask:false];
    [currentLayer addSublayer:imageLayer];
}

- (void)didClickSingleProductMenuDetail:(Clothes *)product
{
    [self removeMenuViewIfDisplay];
    if(self.delegate && [self.delegate respondsToSelector:@selector(modelView:didClickProductDetail:)])
    {
        [self.delegate modelView:self didClickProductDetail:product];
    }
    
    [[DJStatisticsLogic instance] addTraceLog: [DJStatisticsKeys FittingRoom_Click_ViewDetails]];
}

- (void)didClickSingleProductMenuTakeOff:(Clothes *)product
{
    [self removeMenuViewIfDisplay];
    if(self.delegate && [self.delegate respondsToSelector:@selector(modelView:didClickTakeOff:)])
    {
        [self.delegate modelView:self didClickTakeOff:product];
    }
    [[DJStatisticsLogic instance] addTraceLog: [DJStatisticsKeys FittingRoom_Click_TakeOff]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self pointInside:point withEvent:event];
    
    NSMutableArray *selectProducts = [NSMutableArray new];
    
    for(Clothes *pdt in self.currentProducts)
    {
        WearableImage *back= pdt.rightWearableImage;
        if(back)
        {
            if (CGRectContainsPoint([self transformImageRectToView:back.rect], point))
            {
                [selectProducts addObject:pdt];
                continue;
            }
        }
        WearableImage *right= pdt.rightWearableImage;
        if(right)
        {
            if (CGRectContainsPoint([self transformImageRectToView:right.rect], point))
            {
                [selectProducts addObject:pdt];
                continue;
            }
        }
        
        WearableImage *front= pdt.frontWearableImage;
        if(front)
        {
            if (CGRectContainsPoint([self transformImageRectToView:front.rect], point))
            {
                [selectProducts addObject:pdt];
                continue;
            }
        }
        
        WearableImage *left= pdt.leftWearableImage;
        if(left)
        {
            if (CGRectContainsPoint([self transformImageRectToView:left.rect], point))
            {
                [selectProducts addObject:pdt];
                continue;
            }
        }
        
        WearableImage *head= pdt.headWearableImage;
        if(head)
        {
            if (CGRectContainsPoint([self transformImageRectToView:head.rect], point))
            {
                [selectProducts addObject:pdt];
                continue;
            }
        }
    }
    if(selectProducts.count > 1)
    {
        [self displayMultiProductsMenu:selectProducts onPoint:point];
    }
    else if(selectProducts.count > 0)
    {
        [self displaySingleProductMenu:selectProducts[0] onPoint:point];
    }
    else
    {
        [self removeMenuViewIfDisplay];
    }
    [[DJStatisticsLogic instance] addTraceLog: [DJStatisticsKeys FittingRoom_Click_Model]];
}

-(void)displayMultiProductsMenu:(NSArray *)products onPoint:(CGPoint)position
{
    if([self removeMenuViewIfDisplay])
    {
        return;
    }
    CGRect frame = CGRectMake(position.x - kDJMenuArrowX - 5, position.y, kDJMultiProductMenuCellWidth * products.count,  kDJMultiProductMenuHeight);
    int arrowDirection = 0;
    if(products.count > 3)
    {
        frame.origin.x -= kDJMultiProductMenuCellWidth;
        arrowDirection = DJProductMenuViewArrowDirectionCenter;
    }
    if(frame.origin.y > self.bounds.size.height - frame.size.height)
    {
        frame.origin.y = frame.origin.y - frame.size.height - 5;
        self.multiMenuView = [[DJMultiProductsMenuView alloc] initWithFrame:frame products:products arrowDirection:DJProductMenuViewArrowDirectionDown | arrowDirection];
    }
    else
    {
        self.multiMenuView = [[DJMultiProductsMenuView alloc] initWithFrame:frame products:products arrowDirection:DJProductMenuViewArrowDirectionUp | arrowDirection];
    }
    self.multiMenuView.delegate = self;
    self.multiMenuView.alpha = 0;
    [self addSubview:self.multiMenuView];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.multiMenuView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

-(void)didClickSingleProductMenuTuck:(Clothes *)product{
    [self removeMenuViewIfDisplay];
    self.tuck = !self.tuck;
    [self refreshModelWithClothes:self.currentProducts];
}

-(BOOL)showTakeOff:(Clothes *)product{
    if (product.uniqueID == self.mustTryClothes.uniqueID) {
        return false;
    }
    return true;
}

-(BOOL)showDetail:(Clothes *)product{
    if ([self isBags:product] || [self isShoes:product]) {
        return false;
    }
    return true;
}

-(void)displaySingleProductMenu:(Clothes *)product onPoint:(CGPoint)position
{
    if([self removeMenuViewIfDisplay])
    {
        return;
    }
    float menuHeight = kDJSigleProductMenuHeight;
    
    BOOL tuckOption = ([self canTuckTop:product] && self.tuckable);
    BOOL showTakeOff = [self showTakeOff: product];
    BOOL showDetail = [self showDetail:product];
    
    if (tuckOption) {
        menuHeight += 31;
    }
    if (!showDetail) {
        menuHeight -= 31;
    }
    if (!showTakeOff) {
        menuHeight -= 31;
    }
    
    NSString *tuckValue = @"Tuck";
    if (self.tuck) {
        tuckValue = @"UnTuck";
    }
    CGRect frame = CGRectMake(position.x - kDJMenuArrowX - 5, position.y, kDJSigleProductMenuWidth, menuHeight);
    
    if(frame.origin.y > self.bounds.size.height - frame.size.height)
    {
        frame.origin.y = frame.origin.y - frame.size.height - 5;
        self.singleMenuView = [[DJSingleProductMenuView alloc] initWithFrame:frame product:product arrowDirection:DJProductMenuViewArrowDirectionDown showTuckOption:tuckOption tuckValue:tuckValue showTakeoff:showTakeOff showDetail:showDetail];
    }
    else
    {
        self.singleMenuView = [[DJSingleProductMenuView alloc] initWithFrame:frame product:product arrowDirection:DJProductMenuViewArrowDirectionUp showTuckOption:tuckOption tuckValue:tuckValue showTakeoff:showTakeOff showDetail:showDetail];
    }
    
    self.singleMenuView.delegate = self;
    self.singleMenuView.alpha = 0;
    [self addSubview:self.singleMenuView];
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.singleMenuView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

-(BOOL)removeMenuViewIfDisplay
{
    BOOL result = NO;
    if(self.multiMenuView && [self.multiMenuView superview])
    {
        [self.multiMenuView removeFromSuperview];
        self.multiMenuView = nil;
        result = YES;
    }
    if(self.singleMenuView && [self.singleMenuView superview])
    {
        [self.singleMenuView removeFromSuperview];
        self.singleMenuView = nil;
        result = YES;
    }
    return result;
}


- (void)productsMenuView:(DJMultiProductsMenuView *)productMenuView didSelectProduct:(Clothes *)product
{
    CGPoint point = CGPointMake(self.multiMenuView.center.x, self.multiMenuView.frame.origin.y);
    [self removeMenuViewIfDisplay];
    [self displaySingleProductMenu:product onPoint:point];
}

-(BOOL)isNeatlyDressedWithAlert
{
    BOOL result = !self.shouldWearBasicSuntop && !self.shouldWearBasicPants && self.wearedShoes;
    if (result) {
        return true;
    }
    
    NSString *message = MOLocalizedString(@"Make sure the model is fully dressed. Please include:\n - %@", @"");
    if (self.shouldWearBasicPants) {
        message = [NSString stringWithFormat:message, @"bottoms"];
    }
    if (self.shouldWearBasicSuntop) {
        message = [NSString stringWithFormat:message, @"tops"];
    }
    if (!self.wearedShoes) {
        message = [NSString stringWithFormat:message, @"shoes"];
    }
    
    DJAlertView * alertView = [[DJAlertView alloc] initWithTitle:MOLocalizedString(@"Incomplete Style", @"") message:message delegate:nil cancelButtonTitle:MOLocalizedString(@"Ok", @"") otherButtonTitles:nil];
    [alertView show];
    
    return false;
}

-(BOOL)isBags:(Clothes *)pdt{
    return [self.bagSubCateIds containsObject:@(pdt.subCategoryID.integerValue)] || [self.bagSubCateIds containsObject:@(pdt.categoryID.integerValue)];
}

-(BOOL)canTuckTop:(Clothes *)pdt
{
    return [self.tuckSubCateIds containsObject:@(pdt.subCategoryID.integerValue)] || [self.tuckSubCateIds containsObject:@(pdt.categoryID.integerValue)];
}

-(BOOL)showTuckOption:(Clothes *)pdt{
    return ([self canTuckTop:pdt] && self.tuckable);
}

-(BOOL)isShoes:(Clothes *)pdt
{
    return [self.shoesSubCateIds containsObject:@(pdt.subCategoryID.integerValue)] || [self.shoesSubCateIds containsObject:@(pdt.categoryID.integerValue)];
}

-(BOOL)isTopItem:(Clothes *)pdt
{
    return [self.topSubCateIds containsObject:@(pdt.subCategoryID.integerValue)] || [self.topSubCateIds containsObject:@(pdt.categoryID.integerValue)];
}

-(BOOL)isBottomItem:(Clothes *)pdt
{
    return [self.bottomSubCateIds containsObject:@(pdt.subCategoryID.integerValue)] || [self.bottomSubCateIds containsObject:@(pdt.categoryID.integerValue)];
}

-(BOOL)isGlasses:(Clothes *)pdt
{
    if(pdt.subCategoryID.integerValue == 58)
    {
        return YES;
    }
    return NO;
}

-(NSMutableArray *)topSubCateIds{
    if (!_topSubCateIds) {
        //_topSubCateIds = [NSMutableArray arrayWithObjects:@17, @7, @1, @11, @13, @72, @16, @74, @75, @76, @77, @85, @23, @68, @25, @26, nil];
        _topSubCateIds = [NSMutableArray arrayWithObjects:
                          @17,
                          @18,
                          @585,
                          @495,
                          @498,
                          @499,
                          @569,
                          @570,
                          @571,
                          @573,
                          @678,
                          @679,
                          @193,
                          @194,
                          @195,
                          @197,
                          @199,
                          @200,
                          @574,
                          @680,
                          @586,
                          @587,
                          @685,
                          nil];
    }
    return _topSubCateIds;
}

-(NSMutableArray *)bottomSubCateIds{
    if (!_bottomSubCateIds) {
        // _bottomSubCateIds = [NSMutableArray arrayWithObjects:@85, @30, @31, @32, @36, @81, @82, @83, @33, @84, @23, @25, @26, @68, @27, @28, @29, @69, @70, @71, @2, @1, nil];
        _bottomSubCateIds = [NSMutableArray arrayWithObjects:
                             @17,
                             @19,
                             @21,
                             @585,
                             @495,
                             @498,
                             @499,
                             @569,
                             @570,
                             @571,
                             @573,
                             @678,
                             @679,
                             @202,
                             @203,
                             @204,
                             @205,
                             @206,
                             @207,
                             @575,
                             @576,
                             @682,
                             @488,
                             @560,
                             @581,
                             @582,
                             @583,
                             @584,
                             @684,
                             @586,
                             @587,
                             @685,
                             nil];
    }
    return _bottomSubCateIds;
}

-(NSMutableArray *)shoesSubCateIds{
    if (!_shoesSubCateIds) {
        //_shoesSubCateIds = [NSMutableArray arrayWithObjects:@99, @39, @40, @41, @42, @44, @90, nil];
        _shoesSubCateIds = [NSMutableArray arrayWithObjects:
                            @23,
                            @505,
                            @506,
                            @507,
                            @508,
                            @509,
                            @510,
                            @511,
                            @512,
                            @513,
                            @515,
                            @692, nil];
    }
    return _shoesSubCateIds;
}

-(NSMutableArray *)tuckSubCateIds{
    if (!_tuckSubCateIds) {
        //_tuckSubCateIds = [NSMutableArray arrayWithObjects:@11, @13, @72, @16, @74, @75, @76, @77, nil];
        _tuckSubCateIds = [NSMutableArray arrayWithObjects:
                           @18,
                           @193,
                           @194,
                           @195,
                           @197,
                           @199,
                           @200,
                           @574,
                           @680,
                           nil];
    }
    return _tuckSubCateIds;
}

-(NSMutableArray *)bagSubCateIds{
    if (!_bagSubCateIds) {
        _bagSubCateIds = [NSMutableArray arrayWithObjects:
                          @24,
                          @522,
                          @523,
                          @524,
                          @527,
                          @529,
                          @664,
                          @693,
                          nil];
    }
    return _bagSubCateIds;
}

@end
