//
//  DJFaceView.m
//  DejaFasion
//
//  Created by Jiao Qing on 17/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "DJFaceView.h"
#import "DJMakeupPosition.h"
#import "DJSelectionModels.h"
#import "DJColorMap.h"
#import "DJFileManager.h"
#import "DejaFashion-swift.h"

/** The images' original size under same scale ratio.
 * face is 510px by 510px, here we scale all of them in point.
 * Just keep the same scale ratio, we can recover the face.
 */
#define kFaceImageSize      510 // The default image size for face, hair, ears, shadowdown and shadowup.
#define kBrowImageWidth     87
#define kBrowImageHeight    32
#define kNoseImageWidht     70
#define kNoseImageHeight    140
#define kMouthImageWdith    91
#define kMouthImageHeight   52
#define kMakeupImageWidth   172
#define kMakeupImageHeight  172
#define kEyeImageWidth      172
#define kEyeImageHeight     172
#define kShadowupImageWidth 118
#define kShadowupImageHeight 80

#define kDrawImageFullScale (float)([[UIScreen mainScreen] scale] * 1.4)

/** When pressed save, djSkinColor, djHairColor, djMakeupIndex will saved on the disk. */

@interface DJFaceView ()
@property (nonatomic, strong) NSString *djSkinColor;
@property (nonatomic, strong) NSString *djHairColor;
@property (nonatomic, strong) NSString *djHairIndex;
@property (nonatomic, strong) NSString *djMakeupIndex;

@property (nonatomic, strong) NSDictionary *faceSpecification; // Store the information of parts.
@end


@implementation DJFaceView {
    NSString *_genderString;
    
    int _headOffSetX;
    int _headOffSetY;
    
    float _viewScale;
    CGFloat _djHeadViewWidth;
    CGFloat _djHeadViewHeight;
    
    NSString *_eyeIndex;
    
    NSArray * _posJsonMouse;
    NSArray * _scaleJsonMouse;
    CGAffineTransform _matrixJsonMouse;
    
    CGLayerRef _eyeRightLayer;
    CGLayerRef _eyeRightPupilLayer;
    CGLayerRef _eyeMulRightLayer;
    CGLayerRef _browRightLayer;
    CGLayerRef _halfBodyLayer;
    CGLayerRef _shadowupLeftLayer;
    CGLayerRef _rightBrowLayer;
    
    UIImage *_basicFace;
    UIImage *_rightBrow;
    
    NSArray *_posJsonLeftBrow;
    NSArray *_scaleJsonLeftBrow;
    NSArray *_posJsonRightBrow;
    NSArray *_scaleJsonRightBrow;
    CGAffineTransform _matrixJsonLeftBrow;
    CGAffineTransform _matrixJsonRightBrow;
    
    float _xMoveLeftEye;
    float _yMoveLeftEye;
    float _eyeScalex;
    float _eyeScaley;
    float _xMoveRightEye;
    float _yMoveRightEye;
    float _xMoveMakeUPRight;// From canthuspin.txt.
    float _yMoveMakeUPRight;
    float _browScale;
    
    CGRect _makeupRectRight;
    UIImage *_makeupRightMask;
    CGAffineTransform _matrixJsonEye;
    UIImage *_maskedMakeUp;
}

@synthesize faceSpecification = _faceSpecification;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _djHeadViewWidth = frame.size.width;
        _djHeadViewHeight = frame.size.height;
        _viewScale = _djHeadViewWidth / 510;
        
        _genderString = @"f";
        _faceSpecification = (NSMutableDictionary *)[[FittingRoomDataContainer sharedInstance] getDefaultDejaFaceData];
        
        NSArray *headOffSetResult = [_faceSpecification objectForKey:kFaceoffsetInJason];
        _headOffSetX = [[headOffSetResult objectAtIndex:0] intValue];
        _headOffSetY = [[headOffSetResult objectAtIndex:1] intValue];
        
        self.djMakeupIndex = kDefaultMakeupID;
        self.djSkinColor = kDefaultSkinColor;
        self.djHairColor = kDefaultHairColor;
        self.djHairIndex = kDefaultHairStyleID;
        
        [self prepareStaticParts];
    }
    return self;
}
 
- (UIImage *)getFaceWithColor:(NSString *)skinColor MakeupId:(NSString *)makeupId hairColor:(NSString *)hairColor{
    self.djMakeupIndex = makeupId;
    self.djSkinColor = skinColor;
     self.djHairColor = hairColor;
    [self refreshMakeupChangeRelated];
    [self composeWholeFace];
    
    return self.wholeFace;
}

- (void)resetHairWithColor:(NSString *)hairColor HairStyleId:(NSString *)hairId{
    self.djHairColor = hairColor;
    self.djHairIndex = hairId;
    [self renderHair:kHairBackIdentifiler];
    [self renderHair:kHairFrontIdentifiler];
}

- (void)renderFaceAndHair {
    [self renderHair:kHairBackIdentifiler];
    [self composeWholeFace];
    [self renderHair:kHairFrontIdentifiler];
}

- (void)prepareStaticParts {
    @autoreleasepool {
        NSDictionary * jsonResult;
        NSString *str;
        NSString *idJson;
        NSArray * posJson;
        NSArray * scaleJson;
        
        //        CGSize oneFaceSize = CGSizeMake(_djHeadViewWidth * kDrawImageFullScale, _djHeadViewWidth * kDrawImageFullScale);
        //        CGRect oneFaceRect = CGRectMake(0, 0, oneFaceSize.width, oneFaceSize.height);
        
        {/** For Brow. */
            jsonResult = [_faceSpecification objectForKey:kBrowsLeftNameInJason];
            _posJsonLeftBrow = [jsonResult objectForKey:@"pos"];
            _scaleJsonLeftBrow = [jsonResult objectForKey:@"scale"];
            NSArray *matrixLeftBrow = [jsonResult objectForKey:@"matrix"];
            _matrixJsonLeftBrow = CGAffineTransformMake([[matrixLeftBrow objectAtIndex:0] floatValue], [[matrixLeftBrow objectAtIndex:2] floatValue], [[matrixLeftBrow objectAtIndex:1] floatValue], [[matrixLeftBrow objectAtIndex:3] floatValue], 0, 0);
            
            jsonResult = [_faceSpecification objectForKey:kBrowsRightNameInJason];
            _posJsonRightBrow = [jsonResult objectForKey:@"pos"];
            _scaleJsonRightBrow = [jsonResult objectForKey:@"scale"];
            NSArray *matrixRightBrow = [jsonResult objectForKey:@"matrix"];
            _matrixJsonRightBrow = CGAffineTransformMake([[matrixRightBrow objectAtIndex:0] floatValue], [[matrixRightBrow objectAtIndex:2] floatValue], [[matrixRightBrow objectAtIndex:1] floatValue], [[matrixRightBrow objectAtIndex:3] floatValue], 0 - kBrowImageWidth * _viewScale, 0);
            
            
            idJson = [jsonResult objectForKey:@"id"];
            
            NSString *strRight = [NSString stringWithFormat:@"r_%@_brow%@r.png", _genderString, idJson];
            if (![DJFileManager isFileExist:strRight]) {
                strRight = [NSString stringWithFormat:@"r_%@_brow%@r.png", _genderString, kDefaultBrowStyleID];
            }
            _rightBrow = [UIImage imageNamed:strRight];
        }
        
        {
            if (_shadowupLeftLayer) {
                CGLayerRelease(_shadowupLeftLayer);
            }
            CGImageRef shadowupImage = [UIImage imageNamed:@"shadowup4l.png"].CGImage;
            
            CGSize shadowupSize = CGSizeMake(kShadowupImageWidth * _viewScale * kDrawImageFullScale, kShadowupImageHeight * _viewScale * kDrawImageFullScale);
            CGRect shadowupRect = CGRectMake(0, 0, shadowupSize.width, shadowupSize.height);
            UIGraphicsBeginImageContext(shadowupSize);
            CGContextRef context = UIGraphicsGetCurrentContext();
            _shadowupLeftLayer = CGLayerCreateWithContext(context, shadowupSize, NULL);
            UIGraphicsEndImageContext();
            
            CGContextRef myLayerContext = CGLayerGetContext(_shadowupLeftLayer);
            CGContextScaleCTM(myLayerContext, 1, -1);
            CGContextTranslateCTM(myLayerContext, 0, -shadowupRect.size.height);
            CGContextDrawImage(myLayerContext, shadowupRect, shadowupImage);
        }
        
        {// For left and right eyes.
            if (_eyeRightLayer){
                CGLayerRelease(_eyeRightLayer);
            }
            jsonResult =[_faceSpecification objectForKey:kEyesLeftNameInJason];
            _eyeIndex = [jsonResult objectForKey:@"id"];
            NSString *strRight = [NSString stringWithFormat:@"r_%@_eye%@r.png", _genderString, _eyeIndex];
            
            if (![DJFileManager isFileExist:strRight]) {
                strRight = [NSString stringWithFormat:@"r_%@_eye%@r.png", _genderString, kDefaultEyeStyleID];
                _eyeIndex = kDefaultEyeStyleID;
            }
            
            CGImageRef eyeRightImage = [UIImage imageNamed:strRight].CGImage;
            
            CGSize eyeSize = CGSizeMake(kEyeImageWidth * _viewScale * kDrawImageFullScale * 1, kEyeImageHeight * _viewScale * kDrawImageFullScale * 1);
            CGRect eyeRect = CGRectMake(0, 0, eyeSize.width, eyeSize.height);
            
            UIGraphicsBeginImageContext(eyeSize);
            CGContextRef context = UIGraphicsGetCurrentContext();
            _eyeRightLayer = CGLayerCreateWithContext (context, eyeSize, NULL);
            UIGraphicsEndImageContext();
            
            CGContextRef eyeRightLayerContext = CGLayerGetContext(_eyeRightLayer);
            CGContextScaleCTM(eyeRightLayerContext, 1, -1);
            CGContextTranslateCTM(eyeRightLayerContext, 0, -eyeRect.size.height);
            CGContextDrawImage(eyeRightLayerContext, eyeRect, eyeRightImage);
            
            if (_eyeMulRightLayer){
                CGLayerRelease(_eyeMulRightLayer);
            }
            NSString *strMulRight = [NSString stringWithFormat:@"r_%@_eye%@_mul_r.png", _genderString, _eyeIndex];
            
            CGImageRef mulRightImage = [UIImage imageNamed:strMulRight].CGImage;
            
            UIGraphicsBeginImageContext(eyeSize);
            context = UIGraphicsGetCurrentContext();
            _eyeMulRightLayer = CGLayerCreateWithContext (context, eyeSize, NULL);
            UIGraphicsEndImageContext();
            
            eyeRightLayerContext = CGLayerGetContext(_eyeMulRightLayer);
            CGContextScaleCTM(eyeRightLayerContext, 1, -1);
            CGContextTranslateCTM(eyeRightLayerContext, 0, -eyeRect.size.height);
            CGContextDrawImage(eyeRightLayerContext, eyeRect, mulRightImage);
            
            if (_eyeRightPupilLayer){
                CGLayerRelease(_eyeRightPupilLayer);
            }
            NSArray *scaleJson = [jsonResult objectForKey:@"scale"];
            _eyeScalex = [[scaleJson objectAtIndex:0] floatValue];
            _eyeScaley = [[scaleJson objectAtIndex:1] floatValue];
            
            NSString *strMaskRight = [NSString stringWithFormat:@"r_%@_eye%@_mask_r.png", _genderString, _eyeIndex];
            
            CGImageRef pupilImage = [UIImage imageNamed:@"r_f_pupil.png"].CGImage;
            CGImageRef maskRightImage = [UIImage imageNamed:strMaskRight].CGImage;
            
            CGRect maskRect = CGRectMake(-eyeSize.width * (_eyeScalex - 1) / 2, -eyeSize.height * (_eyeScaley - 1) / 2, eyeSize.width * _eyeScalex, eyeSize.height * _eyeScaley);
            
            UIGraphicsBeginImageContext(eyeSize);
            context = UIGraphicsGetCurrentContext();
            _eyeRightPupilLayer = CGLayerCreateWithContext (context, eyeSize, NULL);
            UIGraphicsEndImageContext();
            
            CGContextRef rightPupilLayerContext = CGLayerGetContext(_eyeRightPupilLayer);
            CGContextScaleCTM(rightPupilLayerContext, 1, -1);
            CGContextTranslateCTM(rightPupilLayerContext, 0, -eyeRect.size.height);
            CGContextClipToMask(rightPupilLayerContext, maskRect, maskRightImage);
            CGContextDrawImage(rightPupilLayerContext, eyeRect, pupilImage);
        }
        
        {// Compose basic face
            /** face */
            jsonResult =[_faceSpecification objectForKey:kFaceNameInJason];
            str = [NSString stringWithFormat:@"r_%@_%@%@.png", _genderString, kFaceNameInJason, [jsonResult objectForKey:@"id"]];
            if (![DJFileManager isFileExist:str]){
                str = [NSString stringWithFormat:@"r_%@_%@%@.png", _genderString, kFaceNameInJason, kDefaultFaceShapeStyleID];
            }
            UIImage *faceImage = [UIImage imageNamed:str];
            
            /** Position, Scale Information for Eyes. */
            jsonResult =[_faceSpecification objectForKey:kEyesLeftNameInJason];
            posJson = [jsonResult objectForKey:@"pos"];
            scaleJson = [jsonResult objectForKey:@"scale"];
            NSArray * matrixEye = [jsonResult objectForKey:@"matrix"];
            _xMoveLeftEye = [[posJson objectAtIndex:0] floatValue];
            _yMoveLeftEye = [[posJson objectAtIndex:1] floatValue];
            _matrixJsonEye = CGAffineTransformMake([[matrixEye objectAtIndex:0] floatValue], [[matrixEye objectAtIndex:2] floatValue], [[matrixEye objectAtIndex:1] floatValue], [[matrixEye objectAtIndex:3] floatValue], -kEyeImageWidth / 2 * _viewScale, -kEyeImageHeight / 2 * _viewScale);
            jsonResult =[_faceSpecification objectForKey:kEyesRightNameInJason];
            posJson = [jsonResult objectForKey:@"pos"];
            _xMoveRightEye = [[posJson objectAtIndex:0] floatValue];
            _yMoveRightEye = [[posJson objectAtIndex:1] floatValue];
            
            str = [NSString stringWithFormat:@"r_f_eye%@_mask2_r.png", _eyeIndex];
            _makeupRightMask = [UIImage imageNamed:str];
            
            /** Position, Scale Information for Ears. */
            jsonResult = [_faceSpecification objectForKey:kEarsLeftNameInJason];
            idJson = [jsonResult objectForKey:@"id"];
            NSArray * posJsonEar = [jsonResult objectForKey:@"pos"];
            UIImage *leftEar = [UIImage imageNamed:@"ear6l.png"];
            UIImage *rightEar = [UIImage imageNamed:@"ear6r.png"];
            
            /** Position, Scale Information for Nose. */
            jsonResult = [_faceSpecification objectForKey:kNoseNameInJason];
            idJson = [jsonResult objectForKey:@"id"];
            str = [NSString stringWithFormat:@"r_f_nose%@.png", idJson];
            if (![DJFileManager isFileExist:str]){
                str = [NSString stringWithFormat:@"r_f_nose%@.png", kDefaultNoseStyleID];
            }
            UIImage *noseImage = [UIImage imageNamed:str];
            NSArray * posJsonNose = [jsonResult objectForKey:@"pos"];
            NSArray * scaleJsonNose = [jsonResult objectForKey:@"scale"];
            NSArray * matrixNose = [jsonResult objectForKey:@"matrix"];
            CGAffineTransform matrixJsonNose = CGAffineTransformMake([[matrixNose objectAtIndex:0] floatValue], [[matrixNose objectAtIndex:2] floatValue], [[matrixNose objectAtIndex:1] floatValue], [[matrixNose objectAtIndex:3] floatValue], 0, 0);
            
            /** Position, Scale Information for Mouth. */
            jsonResult = [_faceSpecification objectForKey:kMakeUpMouthNameInJason];
            _posJsonMouse = [jsonResult objectForKey:@"pos"];
            _scaleJsonMouse = [jsonResult objectForKey:@"scale"];
            NSArray * matrixMouse = [jsonResult objectForKey:@"matrix"];
            _matrixJsonMouse = CGAffineTransformMake([[matrixMouse objectAtIndex:0] floatValue], [[matrixMouse objectAtIndex:2] floatValue], [[matrixMouse objectAtIndex:1] floatValue], [[matrixMouse objectAtIndex:3] floatValue], 0, 0);
            
            /**Start the whole face composition.
             * Using CGContext to draw and get the Image.
             * Draw the rest parts on the face.
             */
            CGSize fullSize = CGSizeMake(_djHeadViewWidth, _djHeadViewWidth);
            UIGraphicsBeginImageContextWithOptions(fullSize, NO, kDrawImageFullScale);
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            
            // Ear
            CGRect earRect = CGRectMake([[posJsonEar objectAtIndex:0] floatValue] * _viewScale, [[posJsonEar objectAtIndex:1] floatValue] * _viewScale, fullSize.width, fullSize.width);
            [leftEar drawInRect:earRect];
            [rightEar drawInRect:earRect];
            
            // Face
            CGRect faceRect = CGRectMake(0, 0, _djHeadViewWidth, _djHeadViewWidth);
            CGContextSaveGState(currentContext);
            [faceImage drawInRect:faceRect];
            CGContextRestoreGState(currentContext);
            
            // Blush
            CGImageRef blushImg = [UIImage imageNamed:@"blush2.png"].CGImage;
            CGContextSaveGState(currentContext);
            CGContextScaleCTM(currentContext, 1, -1);
            CGContextTranslateCTM(currentContext, 0, -faceRect.size.height);
            CGContextClipToMask(currentContext, faceRect, faceImage.CGImage);
            CGContextDrawImage(currentContext, faceRect, blushImg);
            CGContextRestoreGState(currentContext);
            
            
            // Nose
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, [[posJsonNose objectAtIndex:0] floatValue] * _viewScale, [[posJsonNose objectAtIndex:1] floatValue] * _viewScale);
            CGContextScaleCTM(currentContext, [[scaleJsonNose objectAtIndex:0] floatValue], [[scaleJsonNose objectAtIndex:1] floatValue]);
            CGContextConcatCTM(currentContext, matrixJsonNose);
            CGRect noseRect = CGRectMake(0, 0, kNoseImageWidht * _viewScale, kNoseImageHeight * _viewScale);
            [noseImage drawInRect:noseRect];
            CGContextRestoreGState(currentContext);
            
            _basicFace = UIGraphicsGetImageFromCurrentImageContext();// The final image.
            UIGraphicsEndImageContext();
        }
    }
    
    [self refreshMakeupChangeRelated];
}

- (void)refreshMakeupChangeRelated {
    @autoreleasepool {
        NSInteger makeV = [self.djMakeupIndex integerValue];
        if (makeV < 1) {
            _maskedMakeUp = nil;
        }
        else {
            NSString *strMakeup = [NSString stringWithFormat:@"makeup%@r.png", self.djMakeupIndex];
            UIImage *makeupRightImage = [UIImage imageNamed:strMakeup];
            
            NSDictionary *makeupPosFile = [[DJMakeupPosition makeupPosistion] objectForKey:[NSString stringWithFormat:@"makeup%@",self.djMakeupIndex]];
            NSArray * makeupPos = [makeupPosFile objectForKey:[NSString stringWithFormat:@"%@",_eyeIndex]];
    
            if ([makeupPos count] == 2) {
                _xMoveMakeUPRight = [makeupPos[0] intValue];// From canthuspin.txt.
                _yMoveMakeUPRight = [makeupPos[1] intValue];
            }else {
                _xMoveMakeUPRight = 0;
                _yMoveMakeUPRight = 0;
            }
            
            if ([self.djMakeupIndex integerValue] == 6) {
                _xMoveMakeUPRight += 3;
            }
            if ([self.djMakeupIndex integerValue] == 8) {
                _xMoveMakeUPRight += 2;
                _yMoveMakeUPRight += 1;
            }
            if ([self.djMakeupIndex integerValue] == 7) {
                _yMoveMakeUPRight += 2;
            }
            if ([self.djMakeupIndex integerValue] == 2) {
                _xMoveMakeUPRight += 1;
            }
            
            _makeupRectRight = CGRectMake(_xMoveMakeUPRight * _viewScale, _yMoveMakeUPRight * _viewScale, kMakeupImageWidth * _viewScale, kMakeupImageHeight * _viewScale);
            
            CGRect rect = CGRectMake(-_xMoveMakeUPRight * _viewScale * kDrawImageFullScale, -_yMoveMakeUPRight * _viewScale * kDrawImageFullScale, kMakeupImageWidth * _viewScale * kDrawImageFullScale, kMakeupImageHeight * _viewScale * kDrawImageFullScale);
            CGRect rect2 = CGRectMake(0, 0, rect.size.width, rect.size.height);
            UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
            if (true) {
                [_makeupRightMask drawInRect:rect];
                [makeupRightImage drawInRect:rect2 blendMode:kCGBlendModeSourceOut alpha:1];
            }else{
                [makeupRightImage drawInRect:rect2];
            }
            _maskedMakeUp = UIGraphicsGetImageFromCurrentImageContext();// The final image.
            UIGraphicsEndImageContext();
        }
    }
}

- (void)refreshBrow {
    @autoreleasepool {
        float rotateV = 0;
        _browScale = 1;
        _browScale = 1.12;
        
        if (_browRightLayer){
            CGLayerRelease(_browRightLayer);
        }
        CGSize browSize = CGSizeMake(kBrowImageWidth * _viewScale * kDrawImageFullScale * _browScale, kBrowImageHeight * _viewScale * kDrawImageFullScale * _browScale);
        CGRect browRect = CGRectMake(0, 0, kBrowImageWidth * _viewScale * kDrawImageFullScale, kBrowImageHeight * _viewScale * kDrawImageFullScale);
        UIGraphicsBeginImageContext(browSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        _browRightLayer = CGLayerCreateWithContext(context, browSize, NULL);
        UIGraphicsEndImageContext();
        
        UIColor *colorFill = [UIColor colorFromHexString:self.djHairColor];
        
        CGContextRef myLayerContext = CGLayerGetContext(_browRightLayer);
        // From lower left
        CGContextRotateCTM(myLayerContext, [self radians:rotateV]);
        CGContextScaleCTM(myLayerContext, _browScale, _browScale);
        //CGContextTranslateCTM(myLayerContext, trX * _viewScale, trY * _viewScale);
        CGContextScaleCTM(myLayerContext, 1, -1);
        CGContextTranslateCTM(myLayerContext, 0, -browRect.size.height);
        
        CGContextSetBlendMode(myLayerContext, kCGBlendModeOverlay);
        CGContextClipToMask(myLayerContext, browRect, _rightBrow.CGImage);
        CGContextSetFillColorWithColor(myLayerContext, colorFill.CGColor);
        CGContextFillRect(myLayerContext, browRect);
        CGContextDrawImage(myLayerContext, browRect, _rightBrow.CGImage);
    }
}

- (void)composeWholeFace {
    @autoreleasepool {
        /** Position, Scale Information for Brow and Shadowup */
        CGFloat rotateShadowupLeft = 0;
        CGFloat rotateShadowupRight = 0;
        UIImage *shadowMouthImage;
        UIImage *mouthImage;
        if ([self.djMakeupIndex integerValue] > 0) {
            NSMutableDictionary *makeupProfile = [[DJColorMap makeupColorMap] objectForKey:[NSString stringWithFormat:@"makeup%@", self.djMakeupIndex]];
            rotateShadowupLeft = [[makeupProfile objectForKey:@"brow_l_rot"] floatValue];
            rotateShadowupRight = [[makeupProfile objectForKey:@"brow_r_rot"] floatValue];
            
            NSString *mouthStr = [NSString stringWithFormat:@"mouth%@_shadow.png", self.djMakeupIndex];
            shadowMouthImage = [UIImage imageNamed:mouthStr];
            mouthStr = [NSString stringWithFormat:@"mouth%@.png", self.djMakeupIndex];
            mouthImage = [UIImage imageNamed:mouthStr];
        }else {
            shadowMouthImage = [UIImage imageNamed:@"mouth46_shadow.png"];
            mouthImage = [UIImage imageNamed:@"mouth46.png"];
            _maskedMakeUp = nil;
        }
        [self refreshBrow];
        
        NSDictionary *jsonResult = [_faceSpecification objectForKey:kBrowsLeftNameInJason];
        NSString *idJson = [jsonResult objectForKey:@"id"];
        float dx = 87 - 118;
        NSMutableDictionary *shado = [DJMakeupPosition getShadowupPosition];
        NSArray *shadowPos = [shado objectForKey:idJson];
        if (!shadowPos) {
            shadowPos = [shado objectForKey:@"1"];
        }
        
        int colorId = [[FittingRoomDataContainer sharedInstance] getSkinColorIdFromColor:_djSkinColor].intValue + 1;
        NSString *layer1Str = [NSString stringWithFormat:@"SkinColor%d1.png", colorId];
        NSString *layer2Str = [NSString stringWithFormat:@"SkinColor%d2.png", colorId];
        UIImage *layer1Image = [UIImage imageNamed:layer1Str];
        UIImage *layer2Image = [UIImage imageNamed:layer2Str];
        
        CGSize fullSize = CGSizeMake(_djHeadViewWidth, _djHeadViewWidth);
        UIGraphicsBeginImageContextWithOptions(fullSize, NO, kDrawImageFullScale);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        // For head and neck alignment
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), _headOffSetX * _viewScale, _headOffSetY * _viewScale);
        
        // Basic Face
        CGRect faceRect = CGRectMake(0, 0, _djHeadViewWidth, _djHeadViewWidth);
        [_basicFace drawInRect:faceRect];
        
        // Shadowup
        {
            CGRect shadowupRect = CGRectMake(0, 0, kShadowupImageWidth * _viewScale, kShadowupImageHeight * _viewScale);
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, [[_posJsonLeftBrow objectAtIndex:0] floatValue] * _viewScale, [[_posJsonLeftBrow objectAtIndex:1] floatValue] * _viewScale);
            //CGContextRotateCTM(currentContext, [self radians:rotateShadowupLeft]);
            CGContextScaleCTM(currentContext, [[_scaleJsonLeftBrow objectAtIndex:0] floatValue], [[_scaleJsonLeftBrow objectAtIndex:1] floatValue]);
            CGContextConcatCTM(currentContext, _matrixJsonLeftBrow);
            CGContextTranslateCTM(currentContext, [[shadowPos objectAtIndex:0] floatValue] * _viewScale, [[shadowPos objectAtIndex:1] floatValue] * _viewScale);
            CGContextTranslateCTM(currentContext, (dx - 78) * _viewScale, (-26) * _viewScale);
            CGContextDrawLayerInRect(UIGraphicsGetCurrentContext(), shadowupRect, _shadowupLeftLayer);
            CGContextRestoreGState(currentContext);
            
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, [[_posJsonRightBrow objectAtIndex:0] floatValue] * _viewScale, [[_posJsonRightBrow objectAtIndex:1] floatValue] * _viewScale);
            //CGContextRotateCTM(currentContext, [self radians:rotateShadowupRight]);
            CGContextScaleCTM(currentContext, [[_scaleJsonRightBrow objectAtIndex:0] floatValue], [[_scaleJsonRightBrow objectAtIndex:1] floatValue]);
            CGContextConcatCTM(currentContext, _matrixJsonRightBrow);
            CGContextTranslateCTM(currentContext, [[shadowPos objectAtIndex:2] floatValue] * _viewScale, [[shadowPos objectAtIndex:3] floatValue] * _viewScale);
            CGContextTranslateCTM(currentContext, (- 9) * _viewScale, (-26) * _viewScale);
            CGContextScaleCTM(currentContext, -1, 1);
            CGContextTranslateCTM(currentContext, -shadowupRect.size.width, 0);
            CGContextDrawLayerInRect(currentContext, shadowupRect, _shadowupLeftLayer);
            CGContextRestoreGState(currentContext);
        }
        
        {  // EyeAround Left
            CGRect eyeRect = CGRectMake(0, 0, kEyeImageWidth * _viewScale, kEyeImageHeight * _viewScale);
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, _xMoveLeftEye * _viewScale, _yMoveLeftEye * _viewScale);
            CGContextScaleCTM(currentContext, _eyeScalex,  _eyeScaley);
            CGContextConcatCTM(currentContext, _matrixJsonEye);
            CGContextScaleCTM(currentContext, -1, 1);
            CGContextTranslateCTM(currentContext, -eyeRect.size.width, 0);
            CGContextDrawLayerInRect(currentContext, eyeRect, _eyeRightLayer);
            CGContextRestoreGState(currentContext);
            
            // EyeAround Right
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, _xMoveRightEye * _viewScale, _yMoveRightEye * _viewScale);
            CGContextScaleCTM(currentContext, _eyeScalex,  _eyeScaley);
            CGContextConcatCTM(currentContext, _matrixJsonEye);
            CGContextDrawLayerInRect(currentContext, eyeRect, _eyeRightLayer);
            CGContextRestoreGState(currentContext);
        }
        
        {// Brow
            CGRect browRect = CGRectMake(0, -kBrowImageHeight * _viewScale * (_browScale - 1), kBrowImageWidth * _viewScale * _browScale, kBrowImageHeight * _viewScale * _browScale);
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, [[_posJsonLeftBrow objectAtIndex:0] floatValue] * _viewScale, [[_posJsonLeftBrow objectAtIndex:1] floatValue] * _viewScale);
            // CGContextRotateCTM(currentContext, [self radians:rotateLeft]);
            CGContextScaleCTM(currentContext, [[_scaleJsonRightBrow objectAtIndex:0] floatValue], [[_scaleJsonRightBrow objectAtIndex:1] floatValue]);
            CGContextConcatCTM(currentContext, _matrixJsonLeftBrow);
            CGContextScaleCTM(currentContext, -1, 1);// Flip the right brow.
            CGContextTranslateCTM(currentContext, -browRect.size.width / _browScale, 0);
            CGContextDrawLayerInRect(UIGraphicsGetCurrentContext(), browRect, _browRightLayer);
            CGContextRestoreGState(currentContext);
            
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, [[_posJsonRightBrow objectAtIndex:0] floatValue] * _viewScale, [[_posJsonRightBrow objectAtIndex:1] floatValue] * _viewScale);
            // CGContextRotateCTM(currentContext, [self radians:rotateRight]);
            CGContextScaleCTM(currentContext, [[_scaleJsonRightBrow objectAtIndex:0] floatValue], [[_scaleJsonRightBrow objectAtIndex:1] floatValue]);
            CGContextConcatCTM(currentContext, _matrixJsonRightBrow);
            CGContextDrawLayerInRect(currentContext, browRect, _browRightLayer);
            CGContextRestoreGState(currentContext);
        }
        
        {// Mouth Shadow
            CGRect mouthRect = CGRectMake(0, 0, kMouthImageWdith * _viewScale, kMouthImageHeight * _viewScale);
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, [[_posJsonMouse objectAtIndex:0] floatValue] * _viewScale, [[_posJsonMouse objectAtIndex:1] floatValue] * _viewScale);
            CGContextScaleCTM(currentContext, [[_scaleJsonMouse objectAtIndex:0] floatValue], [[_scaleJsonMouse objectAtIndex:1] floatValue]);
            CGContextConcatCTM(currentContext, _matrixJsonMouse);
            [shadowMouthImage drawInRect:mouthRect];
            CGContextRestoreGState(currentContext);
        }
        {// Mouth
            CGRect mouthRect = CGRectMake(0, 0, kMouthImageWdith * _viewScale, kMouthImageHeight * _viewScale);
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, [[_posJsonMouse objectAtIndex:0] floatValue] * _viewScale, [[_posJsonMouse objectAtIndex:1] floatValue] * _viewScale);
            CGContextScaleCTM(currentContext, [[_scaleJsonMouse objectAtIndex:0] floatValue], [[_scaleJsonMouse objectAtIndex:1] floatValue]);
            CGContextConcatCTM(currentContext, _matrixJsonMouse);
            [mouthImage drawInRect:mouthRect];
            CGContextRestoreGState(currentContext);
        }
        
        // Change Color
        CGContextSaveGState(currentContext);
        CGContextScaleCTM(currentContext, 1,  -1);
        CGContextTranslateCTM(currentContext, 0, -faceRect.size.height);
        CGContextClipToMask(currentContext, faceRect, _basicFace.CGImage);
        if (colorId !=1){
            [layer1Image drawInRect:faceRect blendMode:kCGBlendModeNormal alpha:1];
        }
        
        if (colorId ==1){
            [layer2Image drawInRect:faceRect blendMode:kCGBlendModeSoftLight alpha:0.6];
        }else{
            [layer2Image drawInRect:faceRect blendMode:kCGBlendModeSoftLight alpha:1];
        }
        CGContextRestoreGState(currentContext);
        
        // Makeup Eye Eye_mul
        {
            // Makeup + Eye + Eye_Mul (Left)
            CGRect eyeRect = CGRectMake(0, 0, kEyeImageWidth * _viewScale, kEyeImageHeight * _viewScale);
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, _xMoveLeftEye * _viewScale, _yMoveLeftEye * _viewScale);
            CGContextConcatCTM(currentContext, _matrixJsonEye);
            CGContextDrawLayerInRect(currentContext, eyeRect, _eyeRightPupilLayer);
            CGContextRestoreGState(currentContext);
            
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, _xMoveLeftEye * _viewScale, _yMoveLeftEye * _viewScale);
            CGContextScaleCTM(currentContext, _eyeScalex,  _eyeScaley);
            CGContextConcatCTM(currentContext, _matrixJsonEye);
            CGContextScaleCTM(currentContext, -1, 1);
            CGContextTranslateCTM(currentContext, -eyeRect.size.width, 0);
            [_maskedMakeUp drawInRect:_makeupRectRight];
            CGContextSetBlendMode(currentContext, kCGBlendModeMultiply);
            CGContextDrawLayerInRect(currentContext, eyeRect, _eyeMulRightLayer);
            CGContextRestoreGState(currentContext);
            
            // Makeup + Eye + Eye_Mul (Right)
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, _xMoveRightEye * _viewScale, _yMoveRightEye * _viewScale);
            CGContextConcatCTM(currentContext, _matrixJsonEye);
            CGContextDrawLayerInRect(currentContext, eyeRect, _eyeRightPupilLayer);
            CGContextRestoreGState(currentContext);
            
            CGContextSaveGState(currentContext);
            CGContextTranslateCTM(currentContext, _xMoveRightEye * _viewScale, _yMoveRightEye * _viewScale);
            CGContextScaleCTM(currentContext, _eyeScalex,  _eyeScaley);
            CGContextConcatCTM(currentContext, _matrixJsonEye);
            [_maskedMakeUp drawInRect:_makeupRectRight];
            CGContextSetBlendMode(currentContext, kCGBlendModeMultiply);
            CGContextDrawLayerInRect(currentContext, eyeRect, _eyeMulRightLayer);
            CGContextRestoreGState(currentContext);
        }
        
        UIImage *shortFace = UIGraphicsGetImageFromCurrentImageContext();// The final image.
        UIGraphicsEndImageContext();
        
        CGSize longFaceSize = CGSizeMake(shortFace.size.width, shortFace.size.width * 3);
        UIGraphicsBeginImageContextWithOptions(longFaceSize, NO, kDrawImageFullScale);
        [shortFace drawInRect:CGRectMake(0, shortFace.size.width, shortFace.size.width, shortFace.size.width)];
        self.wholeFace = UIGraphicsGetImageFromCurrentImageContext();// The final image.
        UIGraphicsEndImageContext();
    }
}

- (void)renderHair:(NSString *)key  {
    @autoreleasepool {
        NSString *str;
        UIImage *hairImage;
        if ([key isEqualToString:kHairBackIdentifiler]) {
            str = [NSString stringWithFormat:@"r_%@_hair%@_back.png",_genderString, self.djHairIndex];
            NSString *strFront = [NSString stringWithFormat:@"r_%@_hair%@_front.png", _genderString, self.djHairIndex];
            if (![DJFileManager isFileExist:str] && [DJFileManager isFileExist:strFront]){
                self.backHair = nil;
                return;
            }
            // If the front hair is not exist, also use the default hair's back hair.
            if (![DJFileManager isFileExist:strFront] ){
                str = [NSString stringWithFormat:@"r_%@_hair%@_back.png", _genderString, kDefaultHairStyleID];
            }
        }
        else if ([key isEqualToString:kHairFrontIdentifiler]) {
            str = [NSString stringWithFormat:@"r_%@_hair%@_front.png", _genderString, self.djHairIndex];
            if (![DJFileManager isFileExist:str]){
                str = [NSString stringWithFormat:@"r_%@_hair%@_front.png", _genderString, kDefaultHairStyleID];
            }
        }
        hairImage = [UIImage imageNamed:str];
        
        CGSize fullSize = CGSizeMake(_djHeadViewWidth, _djHeadViewWidth * 3);
        CGRect rect = CGRectMake(0, 0, fullSize.width, fullSize.height);
        
        UIGraphicsBeginImageContextWithOptions(fullSize, NO, kDrawImageFullScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, 0 - rect.size.height);
        CGContextTranslateCTM(context, 0 - _headOffSetX * _viewScale, 0 -_headOffSetY * _viewScale);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
        
        CGImageRef maskImage = [hairImage CGImage];
        CGContextClipToMask(context, rect, maskImage);
        UIColor *colorFill = [UIColor colorFromHexString:self.djHairColor];
        CGContextSetFillColorWithColor(context, colorFill.CGColor);
        CGContextFillRect(context, rect);
        CGContextDrawImage(context, rect, maskImage);
        
        if ([key isEqualToString:kHairBackIdentifiler]) {
            self.backHair = UIGraphicsGetImageFromCurrentImageContext();
        }
        else  if ([key isEqualToString:kHairFrontIdentifiler]) {
            self.frontHair = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        hairImage = nil;
    }
}

- (CGFloat)radians:(float)degrees {
    return degrees * M_PI/180;
}



@end
