//
//  DJConfigDataContainer.h
//  DejaFashion
//
//  Created by Sun lin on 19/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "MOCoreDataContainer.h"
#import "DJConfigObject+Detail.h"
#import "DJUrl.h"


#define KDJImageQualityVeryHigh     (int)(300 * [UIScreen mainScreen].scale)
#define KDJImageQualityHigh         (int)(260 * [UIScreen mainScreen].scale)
#define KDJImageQualityMedium       (int)(200 * [UIScreen mainScreen].scale)
#define KDJImageQualityLow          (int)(140 * [UIScreen mainScreen].scale)
#define KDJImageQualityVeryLow      (int)(80 * [UIScreen mainScreen].scale)

#define kDJCameraPermissionIdentifier @"kDJCameraPermissionIdentifier"
#define kDJAlbumPermissionIdentifier @"kDJAlbumPermissionIdentifier"

#define kDJPhotoPermissionAlertViewTage 1342
#define kDJCameraPermissionAlertViewTage 1343





@interface DJConfigDataContainer : MOCoreDataContainer


//@property(nonatomic ,strong)DJConfigObject *configCategory;

//@property(nonatomic ,strong)DJConfigObject *configFacebookUrl;
//@property(nonatomic ,strong)DJConfigObject *configTwitterUrl;
//@property(nonatomic ,strong)DJConfigObject *configInstagramUrl;
//@property(nonatomic ,strong)DJConfigObject *configWeiboUrl;

//@property(nonatomic ,strong)DJConfigObject *configFeedbackEmail;



//@property(nonatomic, strong, readonly)NSDictionary<NSString *,  DJConfigObject *> *allConfigObjects;

//push control
@property(nonatomic ,assign)BOOL pushControlDealAlertOn;
@property(nonatomic ,assign)BOOL hasPromoDealAlertRequestPermission;

@property (nonatomic, assign) NSInteger newWardrobeCount;
@property (nonatomic, assign) NSInteger newFavouriteCount;


@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *tutorialVersion;
@property (nonatomic, strong) NSMutableDictionary *hasDisplayPromoAlert;
@property (nonatomic, assign) BOOL tuck;








@property (nonatomic, assign) BOOL handledPushAccessPermission;

//@property (nonatomic, assign) NSString *cartId;

+ (instancetype)instance;

-(NSInteger)openAppCounterIncreaseOne:(BOOL)add;//and return the current opened time

-(BOOL)checkPermissionForKey:(NSString *)key;
-(void)showAccessAlertViewForKey:(NSString *)key;
-(void)showEnableAccessAlertViewForKey:(NSString *)key withViewDelegate:(id)viewDelegate;

-(void)showEnableAccessAlertViewForKey:(NSString *)key;


@end
