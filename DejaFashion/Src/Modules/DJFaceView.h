//
//  DJFaceView.h
//  DejaFashion
//
//  Created by Sun lin on 17/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//(void (^)(int result))completionHandler

// Have to makesure following items are exist, they are the replacement for the missing materials.
#define kDefaultHairStyleID @"9"
#define kDefaultMakeupID @"0"
#define kDefaultHairColor @"6b5a47"
#define kDefaultSkinColor @"e3bda9"
#define kDefaultFaceShapeStyleID @"6"
#define kDefaultEyeStyleID @"239"
#define kDefaultEarStyleID @"6"
#define kDefaultNoseStyleID @"12"
#define kDefaultMouthStyleID @"72"
#define kDefaultMakeupMouthStyleID @"1"
#define kDefaultBrowStyleID @"23"


/** The same name as in Json. */
#define kFaceNameInJason          @"face"
#define kHairNameInJason          @"hair"
#define kEarsLeftNameInJason      @"ear_l"
#define kEarsRightNameInJason     @"ear_r"
#define kBrowsLeftNameInJason     @"brow_l"
#define kBrowsRightNameInJason    @"brow_r"
#define kEyesLeftNameInJason      @"eyes_l"
#define kEyesRightNameInJason     @"eyes_r"
#define kMouthNameInJason         @"mouth"
#define kMakeUpMouthNameInJason   @"makeup_mouth"
#define kNoseNameInJason          @"nose"
#define kDetailNameInJason        @"detail"
#define kBeard_uNameInJason       @"beard_u"
#define kBeard_dNameInJason       @"beard_d"
#define kBeard_sNameInJason       @"beard_s"
#define kBlushNameInJason         @"blush"
#define kGlassNameInJason         @"glasses"
#define kFaceoffsetInJason        @"faceoffset"
#define kMakeupMouthInJason       @"makeup_mouth"

/** Back and front hair are implied. */
#define kHairBackIdentifiler      @"hairb"
#define kHairFrontIdentifiler     @"hairf"

@protocol DJFaceEditProtocol
- (void)enableSaveButton; // Log the djSkinColorIndex, djHairColorIndex, _djMakeupIndex
@end


@interface DJFaceView : UIView

@property (nonatomic, strong) UIImage *backHair;
@property (nonatomic, strong) UIImage *frontHair;
@property (nonatomic, strong) UIImage *wholeFace;

- (UIImage *)getFaceWithColor:(NSString *)skinColor MakeupId:(NSString *)makeupId hairColor:(NSString *)hairColor;
- (void)resetHairWithColor:(NSString *)hairColor HairStyleId:(NSString *)hairId;


@end


