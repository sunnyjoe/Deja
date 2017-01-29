//
//  DJBasicBodyView.m
//  DejaFashion
//
//  Created by jiao qing on 30/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "DJBasicBodyView.h"
#import "DejaFashion-swift.h"

@interface DJBasicBodyView ()

@end


@implementation DJBasicBodyView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UIImageView *bgV = [[UIImageView alloc] initWithFrame:self.bounds];
        bgV.image = [UIImage imageNamed:@"ModelFootShadow"];
        bgV.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bgV];
        
        self.dejaModelLayer = [CALayer layer];
        self.dejaModelLayer.frame = self.bounds;
        [self.layer addSublayer:self.dejaModelLayer];
        
        CGFloat faceRectW = 510 * DJFaceScale;
        CGFloat scale = self.frame.size.width / kDJModelViewWidth3x;
        
        self.dejaFaceRect = CGRectMake(322 * scale , (68 - faceRectW) * scale * 1.05, faceRectW * scale, faceRectW * 3 * scale);
        
        self.viewForReshape = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [self addSubview:self.viewForReshape];
        self.viewForReshape.clipsToBounds = true;
        self.glkView = [RenderGLKView sharedInstance];
    }
    return self;
}

-(CGRect)transformImageRectToView:(CGRect) rect
{
    CGRect result = CGRectZero;
    float scale = self.bounds.size.width / kDJModelViewWidth3x;
    result.origin.x = rect.origin.x * scale;
    result.origin.y = rect.origin.y * scale;
    result.size.width = rect.size.width * scale;
    result.size.height = rect.size.height * scale;
    return result;
}

-(CALayer *)makeLayerWithImage:(UIImage *)orImage frame:(CGRect)frame{
    CALayer *tmplayer = [CALayer layer];
    tmplayer.frame = frame;
    tmplayer.contents = (id)[orImage CGImage];
    tmplayer.contentsScale = 1.0;
    return  tmplayer;
}

-(void)refreshModelOnly
{
    [self.viewForReshape addSubview:self.glkView];
    @autoreleasepool {
        UInt64 time1 = [NSDate currentTimeMillis];
        
        CALayer *renderLayer = [CALayer layer];
        renderLayer.frame = self.bounds;
        
        [self.dejaModelLayer removeAllSubLayers];
        
        [self makeModelBasicLayer];
        self.basicSuntopLayer = [self makeBasicSuntopLayer];
        self.basicPantsLayer = [self makeBasicPantsLayer];
        
        [renderLayer addSublayer:self.backHairLayer];
        [renderLayer addSublayer:self.bodyRightLayer];
        [renderLayer addSublayer:self.bodyLayer];
        [renderLayer addSublayer:self.bodyBreastLayer];
        [renderLayer addSublayer:self.bodyLegLayer];
        [renderLayer addSublayer:self.basicSuntopLayer];
        [renderLayer addSublayer:self.basicPantsLayer];
        [renderLayer addSublayer:self.faceLayer];
        [renderLayer addSublayer:self.bodyLeftLayer];
        [renderLayer addSublayer:self.frontHairLayer];
        
        [self.dejaModelLayer addSublayer:renderLayer];
        
        UInt64 time2 = [NSDate currentTimeMillis] - time1;
        [DJLog info:DJ_UI content:@"Reshape deja model view duration = %d", time2];
    }
}

-(void)makeModelBasicLayer{
    UIImage *bodyFrontImg = [[FittingRoomDataContainer sharedInstance] getBodyFrontImage:self.bodyShape skinColor:self.skinColor];
    UIImage *bodyBreastImg = [[FittingRoomDataContainer sharedInstance] getBodyBreastImage:self.cupSize skinColor:self.skinColor];
    
    NSArray *armImgs = [[FittingRoomDataContainer sharedInstance] getBodyArmImage:self.armShape skinColor:self.skinColor];
    UIImage *bodyLegImg =  [[FittingRoomDataContainer sharedInstance] getBodyLegImage:self.legShape skinColor:self.skinColor];
    
    UIImage *bodyRightImg;
    UIImage *bodyLeftImg;
    if (armImgs) {
        bodyRightImg = armImgs[0];
        bodyLeftImg= armImgs[1];
    }
    NSString *leftArmShape = [NSString stringWithFormat:@"%@l", self.armShape];
    NSString *rightArmShape = [NSString stringWithFormat:@"%@r", self.armShape];
    
    CGRect leftRect = [[FittingRoomDataContainer sharedInstance] getBodyCoordinate:leftArmShape];
    CGRect rightRect = [[FittingRoomDataContainer sharedInstance] getBodyCoordinate:rightArmShape];
    CGRect legRect = [[FittingRoomDataContainer sharedInstance] getBodyCoordinate:self.legShape];
    CGRect bodyRect = [[FittingRoomDataContainer sharedInstance] getBodyCoordinate:self.bodyShape];
    CGRect cupRect = [[FittingRoomDataContainer sharedInstance] getBodyCoordinate:self.cupSize];
    
    self.bodyLayer = [self makeLayerWithImage:bodyFrontImg frame:[self transformImageRectToView:bodyRect]];
    self.bodyBreastLayer = [self makeLayerWithImage:bodyBreastImg frame:[self transformImageRectToView:cupRect]];
    self.bodyRightLayer = [self makeLayerWithImage:bodyRightImg frame:[self transformImageRectToView:rightRect]];
    self.bodyLeftLayer = [self makeLayerWithImage:bodyLeftImg frame:[self transformImageRectToView:leftRect]];
    self.bodyLegLayer = [self makeLayerWithImage:bodyLegImg frame:[self transformImageRectToView:legRect]];
    
    self.faceLayer = [CALayer layer];
    if (self.specailFace) {
        self.faceLayer.frame = self.bounds;
        self.faceLayer.contents = (id)self.specailFace.CGImage;
    }else{
        self.faceLayer.frame = self.dejaFaceRect;
        UIImage *faceImage = [[FittingRoomDataContainer sharedInstance] getWholeFace:self.skinColor makeupId:self.makeupId hairColor:self.hairColor];
        self.faceLayer.contents = (id)faceImage.CGImage;
    }
    
    NSArray *hairImages = [[FittingRoomDataContainer sharedInstance] getHairImages:self.hairColor styleId:self.hairStyleId];
    if (self.specailFrontHair) {
        if (self.specailBackHair) {
            hairImages = [NSArray arrayWithObjects:self.specailFrontHair, self.specailBackHair, nil];
        }else{
            hairImages = [NSArray arrayWithObjects:self.specailFrontHair, nil];
        }
    }
    
    CGRect rect = self.bounds;
    self.frontHairLayer = [CALayer layer];
    self.frontHairLayer.frame = rect;
    if (hairImages.count > 0) {
        UIImage *frontHair = hairImages[0];
        CALayer *frontHairSubLayer = [CALayer layer];
        frontHairSubLayer.frame = self.dejaFaceRect;
        [self.frontHairLayer addSublayer:frontHairSubLayer];
        frontHairSubLayer.contents = (id)frontHair.CGImage;
    }
    
    self.backHairLayer = [CALayer layer];
    self.backHairLayer.frame = rect;
    if (hairImages.count > 1) {
        UIImage *backHair = hairImages[1];
        CALayer *backHairSubLayer = [CALayer layer];
        backHairSubLayer.frame = self.dejaFaceRect;
        [self.backHairLayer addSublayer:backHairSubLayer];
        backHairSubLayer.contents = (id)backHair.CGImage;
    }
    
}

-(CALayer *)makeBasicSuntopLayer
{
//    NSString *suntopShape = [self.bodyShape substringToIndex:3];
    
    CGRect inputRect = [self imageFullRect];
//    NSString *textureData = [DJFileManager getStringFromTxtFile:[NSString stringWithFormat:@"%@ll_basic_suntop_src", suntopShape]];
//    NSString *posData =  [DJFileManager getStringFromTxtFile:[NSString stringWithFormat:@"%@ll_basic_suntop_tar", suntopShape]];
    
    NSString *braImageName = [NSString stringWithFormat:@"%@_bra.png", self.cupSize];
    
//    BOOL success = [self.glkView reshapeImageWith:[UIImage imageNamed:braImageName] imageRect:inputRect textureData:textureData positionData:posData];
    
    CALayer* subLayer = [CALayer layer];
    subLayer.contentsScale = 1.0;
    UIImage *image;
//    if (success) {
//        subLayer.frame = self.bounds;
//        image = [self.glkView reshapedImage];
//    }else{
        subLayer.frame = [self transformImageRectToView:inputRect];
        image = [UIImage imageNamed:braImageName];
//    }
    subLayer.contents = (id)[image CGImage];
    return subLayer;
}

-(CALayer *)makeBasicPantsLayer
{
    NSString *pantsShape = [NSString stringWithFormat:@"%@l%c", [self.bodyShape substringToIndex:3],[self.legShape characterAtIndex:0]];
    
    CGRect inputRect = [self imageFullRect];
    NSString *textureData = [DJFileManager getStringFromTxtFile:[NSString stringWithFormat:@"%@_basic_pants_src", pantsShape]];
    NSString *posData =  [DJFileManager getStringFromTxtFile:[NSString stringWithFormat:@"%@_basic_pants_tar", pantsShape]];
    
    BOOL success = [self.glkView reshapeImageWith:[UIImage imageNamed:@"BasicPants"] imageRect:inputRect textureData:textureData positionData:posData];
    
    CALayer* subLayer = [CALayer layer];
    subLayer.contentsScale = 1.0;
    UIImage *image;
    if (success) {
        subLayer.frame = self.bounds;
        image = [self.glkView reshapedImage];
    }else{
        subLayer.frame = [self transformImageRectToView:inputRect];
        image = [UIImage imageNamed:@"BasicPants"];
    }
    subLayer.contents = (id)[image CGImage];
    return subLayer;
}

-(CGRect)imageFullRect{
    return CGRectMake(0, 0, kDJModelViewWidth3x, kDJModelViewHeight3x);
}

@end
