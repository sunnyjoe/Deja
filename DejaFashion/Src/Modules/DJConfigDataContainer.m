//
//  DJConfig.m
//  DejaFashion
//
//  Created by Sun lin on 19/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJConfigDataContainer.h"
#import "DJConfigObject+Detail.h"
#import "DJAlertView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

#define kDJConfigDebugMode @"kDJConfigDebugMode"
#define kDJConfigTutorialVersion @"kDJConfigTutorialVersion"
#define kDJConfigHasDisplayPromoAlert @"kDJConfigHasDisplayPromoAlert"

#define kDJConfigNewInstallTemp @"kDJConfigNewInstallTemp"



#define kDJUserShoppingCartId                               @"kDJUserShoppingCartId"
#define kDJHandlePushAccessPermission                       @"kDJHandlePushAccessPermission"

//#define kDJConfigObjectEntityName @"DJConfigObject"
//#define kDJConfigIDCategory         @"category"
//#define kDJConfigIDFacebookUrl      @"facebook_url"
//#define kDJConfigIDTwitterUrl       @"twitter_url"
//#define kDJConfigIDInstagramUrl     @"instagram_url"
//#define kDJConfigIDWeiboUrl         @"sina_weibo_url"
//#define kDJConfigIDWeChatAccount    @"wechat_account"
//#define kDJConfigIDFeedbackEmail    @"feedback_email"



#define kDJRateAlertStore @"kDJRateAlertStore"
#define kDJOpenAppCounter @"kDJOpenAppCounter"


#define PushControlDealAlertOn                   @"pushControlDealAlertOn"
#define NewWardrobeCount                   @"NewWardrobeCount"
#define NewFavouriteCount                   @"NewFavouriteCount"
#define HasPromoDealAlertRequestPermission       @"HasPromoDealAlertRequestPermission"

typedef enum {
    kCLAuthorizationStatusNotDetermined = 0, // 用户尚未做出选择这个应用程序的问候
    kCLAuthorizationStatusRestricted,        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
    kCLAuthorizationStatusDenied,            // 用户已经明确否认了这一照片数据的应用程序访问
    kCLAuthorizationStatusAuthorized         // 用户已经授权应用访问照片数据
} CLAuthorizationStatus;

@interface DJConfigDataContainer () <DJAlertViewDelegate>

@property (nonatomic, strong)NSMutableDictionary<NSString *,  DJConfigObject *> *configObjects;

@end

@implementation DJConfigDataContainer
{
    NSString *jsonString;
}

static DJConfigDataContainer *sharedInstance;
+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init
{
    NSAssert(!sharedInstance, @"This should be a singleton class.");
    if (self = [super init]) {
    }
    return self;
}

- (void)didSetup
{
    [super didSetup];
    self.configObjects = [NSMutableDictionary<NSString *,  DJConfigObject *> new];
//    self.configCategory = [self setUpConfigObjectWithId:kDJConfigIDCategory];
    
//    self.configFacebookUrl = [self setUpConfigObjectWithId:kDJConfigIDFacebookUrl];
//    self.configTwitterUrl = [self setUpConfigObjectWithId:kDJConfigIDTwitterUrl];
//    self.configInstagramUrl = [self setUpConfigObjectWithId:kDJConfigIDInstagramUrl];
//    self.configWeiboUrl = [self setUpConfigObjectWithId:kDJConfigIDWeiboUrl];
//    
//    self.configFeedbackEmail = [self setUpConfigObjectWithId:kDJConfigIDFeedbackEmail];
//    if(!self.configCategory)
//    {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"ConfigJson" ofType:@"json" inDirectory:nil];
//        NSData *jsonData = [NSData dataWithContentsOfFile:path];
//        NSError *error;
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
//        [self setConfigData:dict];
//    }
}

//-(NSDictionary<NSString *,DJConfigObject *> *)allConfigObjects {
//    return self.configObjects;
//}

//-(void)setConfigData:(NSDictionary *)dict
//{
//    NSDictionary *config = dict[@"data"];
//    NSDictionary *versions = dict[@"versions"];
//    
//    NSArray<NSString *> *keys = [self.configObjects allKeys];
//    
//    for (NSString *key in keys) {
//        NSObject *configContent = config[key];
//        if (configContent) {
//            DJConfigObject *configObj = [self.configObjects objectForKey:key];
//            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:configContent];
//            configObj.originalData = data;
//            configObj.version = versions[key];
//        }
//    }
//    [self save];
//}

//- (DJConfigObject *)replaceConfigObjectWithConfigID:(NSString *)configID
//{
//    DJConfigObject *configObject = [self getConfigObjectWithID:configID];
//    if (!configObject) {
//        configObject = [self insertObjectForName:kDJConfigObjectEntityName];
//        configObject.configID = configID;
//        return configObject;
//    }
//    return configObject;
//}

-(NSInteger)openAppCounterIncreaseOne:(BOOL)add{
    NSNumber *rate = [[NSUserDefaults standardUserDefaults] objectForKey:kDJOpenAppCounter];
    if (!rate) {
        rate = @(0);
    }
    if (add) {
        rate = [NSNumber numberWithInteger:([rate integerValue] + 1)];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:rate forKey:kDJOpenAppCounter];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return [rate integerValue];
}

//- (DJConfigObject *)setUpConfigObjectWithId:(NSString *)configID version: (NSInteger)version
//{
//    DJConfigObject *configObject = [self replaceConfigObjectWithConfigID:configID];
//    configObject.version = @(version);
//    [self.configObjects setObject:configObject forKey:configID];
//    return configObject;
//}
//
//- (DJConfigObject *)setUpConfigObjectWithId:(NSString *)configID
//{
//    DJConfigObject *configObject = [self replaceConfigObjectWithConfigID:configID];
//    [self.configObjects setObject:configObject forKey:configID];
//    return configObject;
//}

//- (DJConfigObject *)getConfigObjectWithID:(NSString *)configID
//{
//    NSArray *rs = [self getObjectsForName:kDJConfigObjectEntityName idOnly:NO predicate:@"configID=%@", configID];
//    if (!rs.count) {
//        return nil;
//    }
//    DJConfigObject *configObject = rs[0];
//    return configObject;
//}



-(NSInteger)newWardrobeCount
{
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:NewWardrobeCount])
    {
        return [[NSUserDefaults standardUserDefaults] integerForKey:NewWardrobeCount];
    }
    else{
        return 0;
    }
}


- (void)setNewWardrobeCount:(NSInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:NewWardrobeCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(NSInteger)newFavouriteCount
{
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:NewFavouriteCount])
    {
        return [[NSUserDefaults standardUserDefaults] integerForKey:NewFavouriteCount];
    }
    else{
        return 0;
    }
}


- (void)setNewFavouriteCount:(NSInteger)count
{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:NewFavouriteCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (BOOL)pushControlDealAlertOn
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:PushControlDealAlertOn])
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:PushControlDealAlertOn];
    }
    else{
        return YES;
    }
}

- (void)setPushControlDealAlertOn:(BOOL)on
{
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:PushControlDealAlertOn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)hasPromoDealAlertRequestPermission
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:HasPromoDealAlertRequestPermission])
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:HasPromoDealAlertRequestPermission];
    }
    else{
        return NO;
    }
}

- (void)setHasPromoDealAlertRequestPermission:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:HasPromoDealAlertRequestPermission];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




- (BOOL)debugMode
{
#if (defined APPSTORE)
    return NO;
#else
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDJConfigDebugMode];
#endif
}

- (void)setDebugMode:(BOOL)debugMode
{
    [[NSUserDefaults standardUserDefaults] setBool:debugMode forKey:kDJConfigDebugMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)tutorialVersion
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kDJConfigTutorialVersion];
}

- (void)setTutorialVersion:(NSString *)tutorialVersion
{
    [[NSUserDefaults standardUserDefaults] setObject:tutorialVersion forKey:kDJConfigTutorialVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSDictionary *)hasDisplayPromoAlert
{
    NSDictionary *result = [[NSUserDefaults standardUserDefaults] objectForKey:kDJConfigHasDisplayPromoAlert];
    if (result == nil)
    {
        return [NSMutableDictionary new];
    }
    else
    {
        return result;
    }
}

- (void)setHasDisplayPromoAlert:(NSDictionary *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kDJConfigHasDisplayPromoAlert];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//- (BOOL)newInstallTemp
//{
//    return [[NSUserDefaults standardUserDefaults] boolForKey:kDJConfigNewInstallTemp];
//}
//
//- (void)setNewInstallTemp:(BOOL)newinatall
//{
//    [[NSUserDefaults standardUserDefaults] setBool:newinatall forKey:kDJConfigNewInstallTemp];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}



-(void)setCartId:(NSString *)cartId
{
    [[NSUserDefaults standardUserDefaults] setObject:cartId forKey:kDJUserShoppingCartId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)cartId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kDJUserShoppingCartId];
}


-(void)setHandledPushAccessPermission:(BOOL)isHandled
{
    [[NSUserDefaults standardUserDefaults] setBool:isHandled forKey:kDJHandlePushAccessPermission];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)handledPushAccessPermission
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDJHandlePushAccessPermission];
}



#pragma camera alum permission related

-(BOOL)checkPermissionForKey:(NSString *)key{
    if ([key isEqualToString:kDJCameraPermissionIdentifier]) {
        return [self cameraAllowAccess];
    }else if ([key isEqualToString:kDJAlbumPermissionIdentifier]) {
        return [self alumbAllowAccess];
    }
    return NO;
}

-(BOOL)cameraAllowAccess{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied)
    {
        return NO;
    }
    return true;
}

-(BOOL)alumbAllowAccess{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied){
        return NO;
    }else{
        return YES;
    }
}

-(void)showAccessAlertViewForKey:(NSString *)key{
    NSString *keyStr = nil;
    NSInteger messageTag = 0;
    
    if ([key isEqualToString:kDJCameraPermissionIdentifier]) {
        messageTag = kDJCameraPermissionAlertViewTage;
        keyStr = MOLocalizedString(@"'Deja' would like to access your camera", @"");
    }else if ([key isEqualToString:kDJAlbumPermissionIdentifier]) {
        messageTag = kDJPhotoPermissionAlertViewTage;
        keyStr = MOLocalizedString(@"'Deja' would like to access your photos", @"");
    }
    DJAlertView *message = [[DJAlertView alloc] initWithTitle:nil message:keyStr delegate:self cancelButtonTitle:MOLocalizedString(@"Don't Allow", @"") otherButtonTitles:MOLocalizedString(@"OK", @""),nil];
    message.tag = messageTag;
    [message show];
}

-(void)showEnableAccessAlertViewForKey:(NSString *)key{
    [self showEnableAccessAlertViewForKey:key withViewDelegate:nil];
}

-(void)showEnableAccessAlertViewForKey:(NSString *)key withViewDelegate:(id)viewDelegate{
    NSString *keyStr = nil;
    NSInteger messageTag = 0;
    
    if ([key isEqualToString:kDJCameraPermissionIdentifier]) {
        messageTag = kDJCameraPermissionAlertViewTage;
        keyStr = MOLocalizedString(@"Allow Deja to access your camera and start taking photos.", @"");
    }else if ([key isEqualToString:kDJAlbumPermissionIdentifier]) {
        messageTag = kDJPhotoPermissionAlertViewTage;
        keyStr = MOLocalizedString(@"Allow Deja to access your album.", @"");
    }
 
    DJAlertView *message = [[DJAlertView alloc] initWithTitle:nil message:keyStr delegate:viewDelegate cancelButtonTitle:MOLocalizedString(@"Cancel", @"") otherButtonTitles:MOLocalizedString(@"Enable Access", @""),nil];
    message.tag = messageTag;
    [message show];
}

-(void)alertView:(DJAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kDJPhotoPermissionAlertViewTage || alertView.tag == kDJCameraPermissionAlertViewTage) {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}




@end
