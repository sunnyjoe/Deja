//
//  DJBasicBodyView.h
//  DejaFashion
//
//  Created by jiao qing on 30/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DJFaceScale  0.42


@class RenderGLKView;

@interface DJBasicBodyView : UIView

@property (nonatomic, strong) NSString *skinColor;
@property (nonatomic, strong) NSString *hairColor;
@property (nonatomic, strong) NSString *hairStyleId;
@property (nonatomic, strong) NSString *makeupId;
@property (nonatomic, strong) NSString *bodyShape;
@property (nonatomic, strong) NSString *cupSize;
@property (nonatomic, strong) NSString *armShape;
@property (nonatomic, strong) NSString *legShape;

@property (nonatomic, strong) CALayer *frontHairLayer;
@property (nonatomic, strong) CALayer *faceLayer;

@property (nonatomic, strong) CALayer *backHairLayer;
@property (nonatomic, strong) CALayer *bodyRightLayer;
@property (nonatomic, strong) CALayer *bodyLayer;
@property (nonatomic, strong) CALayer *bodyLeftLayer;
@property (nonatomic, strong) CALayer *bodyLegLayer;
@property (nonatomic, strong) CALayer *bodyBreastLayer;

@property (nonatomic, strong) CALayer *basicSuntopLayer;
@property (nonatomic, strong) CALayer *basicPantsLayer;

@property (nonatomic, strong) RenderGLKView *glkView;
@property (nonatomic, assign) CGRect dejaFaceRect;
@property (nonatomic, strong) CALayer *dejaModelLayer;
@property (nonatomic, strong) UIView *viewForReshape;


@property(nonatomic, strong) UIImage *specailFace;
@property(nonatomic, strong) UIImage *specailBackHair;
@property(nonatomic, strong) UIImage *specailFrontHair;

-(void)refreshModelOnly;

-(void)makeModelBasicLayer;
-(CALayer *)makeBasicPantsLayer;
-(CALayer *)makeBasicSuntopLayer;
-(CALayer *)makeLayerWithImage:(UIImage *)orImage frame:(CGRect)frame;
-(CGRect)transformImageRectToView:(CGRect) rect;
-(CGRect)imageFullRect;
@end
