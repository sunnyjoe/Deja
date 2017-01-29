//
//  DJAppCall.m
//  DejaFashion
//
//  Created by Kevin Lin on 6/1/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJAppCall.h"
#import "DJWebViewController.h"
#import "DJConfigDataContainer.h"
#import "DejaFashion-Swift.h"
#import "DJUserFeedbackLogic.h"

#define DJURLSchema @"dejafashion"

#define DJURLHostWeb @"web"

static NSDictionary *hostToAction;

@interface DJUserGuideViewClickDoneAction : NSObject
+ (instancetype)instance;
@end

@implementation DJUserGuideViewClickDoneAction
static DJUserGuideViewClickDoneAction *sharedInstance;
+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

@end

@implementation DJAppCall

+ (void)load
{
    hostToAction = @{ @"itemDetail": NSStringFromSelector(@selector(openItemDetailWithPath:params:)),
                      //                      @"me": NSStringFromSelector(@selector(openMePath:params:)),
                      @"fittingroom": NSStringFromSelector(@selector(openFittingRoomWithPath:params:)),
                      
                      @"scanPriceTag": NSStringFromSelector(@selector(openScanPriceTagWithPath:params:)),
                      @"findByBrands": NSStringFromSelector(@selector(openFindByBrandsWithPath:params:)),
                      @"searchByPhoto": NSStringFromSelector(@selector(searchByPhoto:params:)),
                      @"searchClothes": NSStringFromSelector(@selector(searchClothes:params:)),
                      
                      @"findStyles": NSStringFromSelector(@selector(findStyles:params:)),
                      @"newConversation": NSStringFromSelector(@selector(newConversation:params:)),
                      @"conversationList": NSStringFromSelector(@selector(conversationList:params:)),
                      @"outfit": NSStringFromSelector(@selector(openOutfitWithPath:params:)),
                      @"clothesDetail": NSStringFromSelector(@selector(openClothesDetailWithPath:params:)),
                      @"wardrobeDetail": NSStringFromSelector(@selector(openWardrobeDetailWithPath:params:)),
                      @"brand": NSStringFromSelector(@selector(openBrandClothesWithPath:params:)),
                      @"friendList": NSStringFromSelector(@selector(openFriendListWithPath:params:)),
                      @"messageList": NSStringFromSelector(@selector(openMessageListWithPath:params:)),
                      @"page": NSStringFromSelector(@selector(openViewControllerWithPath:params:)),
                      @"shopLocation": NSStringFromSelector(@selector(openShopMapWithPath:params:)),
                      @"nearby": NSStringFromSelector(@selector(openNearByWithPath:params:)),
                      @"onlineStoreAlert": NSStringFromSelector(@selector(openGlobalAlertPath:params:)),
                      
                      DJURLHostWeb: NSStringFromSelector(@selector(openWebViewWithPath:params:absoluteString:))};
}

+ (NSDictionary *)dictionaryWithQuery:(NSString *)query
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *components = [query componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        NSArray *keyValue = [component componentsSeparatedByString:@"="];
        if (keyValue.count != 2) {
            continue;
        }
        params[keyValue[0]] = keyValue[1];
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    //    url = [NSURL URLWithString:@"dejafashion://creationComment/93828171733418407"];
    //    if (![self canShowViewController]) {
    //        return NO;
    //    }
    
    if ([url.scheme isEqualToString:DJURLSchema] && url.host && hostToAction[url.host]) {
        [DJLog info:DJ_UI content:@"handleOpenURL %@ from application %@", url.absoluteString, sourceApplication];
        
        NSString *path = url.path.length > 1 ? [url.path substringFromIndex:1] : @"";
        NSDictionary *params = [self dictionaryWithQuery:url.query];
        NSString *absoluteString = url.absoluteString;
        
        SEL action = NSSelectorFromString(hostToAction[url.host]);
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:action]];
        [inv setSelector:action];
        [inv setTarget:self];
        // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        [inv setArgument:&(path) atIndex:2];
        [inv setArgument:&(params) atIndex:3];
        //disgusting code, I don't like this
        if([url.host isEqualToString:DJURLHostWeb])
        {
            [inv setArgument:&(absoluteString) atIndex:4];
        }
        [inv invoke];
        return YES;
    }
    //    else if ([url.absoluteString hasPrefix:@"http"]) {
    // [self openWebViewController:url.absoluteString];
    //        return YES;
    //    }
    return NO;
}

+ (void)openItemDetailWithPath:(NSString *)path params:(NSDictionary *)params
{
    if (!path.length) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            ProductDetailViewController *controller = [[ProductDetailViewController alloc] initWithURLString:[[ConfigDataContainer sharedInstance] getProductDetailUrl:path]];
            controller.useSingleWebview = YES;
            [self showViewController:controller];
        }
    });
}

+ (void)openOutfitWithPath:(NSString *)path params:(NSDictionary *)params
{
    if (!path.length) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            StyleViewController *controller = [[StyleViewController alloc] initWithURLString:[[ConfigDataContainer sharedInstance] getOutfitsUrl]];
            controller.useSingleWebview = YES;
            [self showViewController:controller];
        }
    });
}

+ (void)openClothesDetailWithPath:(NSString *)path params:(NSDictionary *)params
{
    if (!path.length) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            ClothDetailViewController *controller = [[ClothDetailViewController alloc] initWithURLString:[[ConfigDataContainer sharedInstance] getClothDetailUrl:path]];
    
            controller.useSingleWebview = YES;
            [self showViewController:controller];
        }
    });
}


+ (void)openShopMapWithPath:(NSString *)path params:(NSDictionary *)params
{
    if (!path.length) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            ShopInfoViewController *controller = [ShopInfoViewController new];
            controller.shopId = path;
            [self showViewController:controller];
        }
    });
}

+ (void)openFindByBrandsWithPath:(NSString *)path params:(NSDictionary *)params
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            AddByBrandViewController *controller = [AddByBrandViewController new];
            [self showViewController:controller];
        }
    });
}

+ (void)openScanPriceTagWithPath:(NSString *)path params:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            AddByScanViewController *controller = [AddByScanViewController new];
            [self showViewController:controller];
        }
    });
}


+ (void)openGlobalAlertPath:(NSString *)path params:(NSDictionary *)params
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
//            NearbyListViewController *controller = [NearbyListViewController new];
            //            controller.shopId = path;
//            [self showViewController:controller];
            
            
//            if ()
//            {
            NSString *promoId = @"";
             NSArray *banners = [[ConfigDataContainer sharedInstance] getFindClothBanners];
                for (FindClothBanner *oneBanner in banners) {
                    if ([oneBanner.bannerId isEqualToString: promoId])
                    {
                        //shou promotion alert
                        
//                        DJAlertView *message = [[DJAlertView alloc] initWithTitle:nil
//                                                                          message:@""
//                                                                         delegate:nil
//                                                                cancelButtonTitle:MOLocalizedString(@"Don't Allow", @"")
//                                                                otherButtonTitles:nil];
//                        message.tag = @"";
//                        [message show];
                        
                        
                        [DJAlertView alertViewWithTitle:MOLocalizedString(@"Network Unavailable", @"")
                                                message:nil
                                      cancelButtonTitle:MOLocalizedString(@"Dismiss", @"")
                                      otherButtonTitles:nil onDismiss:^(int buttonIndex) {
                                          
                                      } onCancel:^{
                                          
                                      }];
                    }
                }
//            }
            
            
        }
    });
}


+ (void)openNearByWithPath:(NSString *)path params:(NSDictionary *)params
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            NearbyListViewController *controller = [NearbyListViewController new];
            //            controller.shopId = path;
            [self showViewController:controller];
        }
    });
}




+ (void)openWardrobeDetailWithPath:(NSString *)path params:(NSDictionary *)params
{
    if (!path.length || [AccountDataContainer.sharedInstance isAnonymous]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            FriendWardrobeViewController *controller = [FriendWardrobeViewController new];
            controller.userId = path;
            [self showViewController:controller];
        }
    });
}

+ (void)openBrandClothesWithPath:(NSString *)path params:(NSDictionary *)params
{
    if (!path.length) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            BrandInfo *info = [[ConfigDataContainer sharedInstance] getBrandInfoById: path];
            ClothResultCondition *cond = [ClothResultCondition new];
            cond.filterCondition.brand = info;
            FindClothResultViewController *controller = [[FindClothResultViewController alloc] initWithEnterInfo:cond];
            [self showViewController:controller];
        }
    });
}

+ (void)openMessageListWithPath:(NSString *)path params:(NSDictionary *)params
{
    if ([AccountDataContainer.sharedInstance isAnonymous]) {
        if ([self canShowViewController]) {
            LoginViewController *controller = [LoginViewController new];
            controller.gotoFriendListIfSuccess = YES;
            [self showViewController:controller];
        }
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            MessageListViewController *controller = [[MessageListViewController alloc] initWithURLString: [ConfigDataContainer.sharedInstance getMessageListUrl]];
            [self showViewController:controller];
        }
    });
}

+ (void)openFriendListWithPath:(NSString *)path params:(NSDictionary *)params
{
    if ([AccountDataContainer.sharedInstance isAnonymous]) {
        if ([self canShowViewController]) {
            LoginViewController *controller = [LoginViewController new];
            controller.gotoFriendListIfSuccess = YES;
            [self showViewController:controller];
        }
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            FriendListViewController *controller = [FriendListViewController new];
            [self showViewController:controller];
        }
    });
}

+ (void)openViewControllerWithPath:(NSString *)path params:(NSDictionary *)params
{
    if (!path.length) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            Class clazz = NSClassFromString([NSString stringWithFormat:@"DejaFashion.%@%@", path, @"ViewController" ]);
            if (clazz == nil) {
                clazz = NSClassFromString([NSString stringWithFormat:@"%@%@", path, @"ViewController" ]);
            }
            if (clazz) {
                FriendListViewController *controller = [[clazz alloc] init];
                [self showViewController:controller];
            }
        }
    });
}


//
//+ (void)openFeedbackWithPath:(NSString *)path params:(NSDictionary *)params
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self canShowViewController]) {
//            [[DJUserFeedbackLogic instance] showConversationList];
//        }
//    });
//}
//
//
//
+ (void)openWebViewWithPath:(NSString *)path params:(NSDictionary *)params absoluteString:(NSString *)absoluteString
{
    NSRange range = [absoluteString rangeOfString:[NSString stringWithFormat:@"%@://%@", DJURLSchema, DJURLHostWeb]];
    NSString *url = [absoluteString substringFromIndex:range.length + 1];
    if (!url) {
        return;
    }
    //    url = [NSString urlDecode:url];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            DJWebViewController *webViewController = [[DJWebViewController alloc] initWithURLString:url];
            webViewController.useSingleWebview = YES;
            webViewController.hidesBottomBarWhenPushed = YES;
            [self showViewController:webViewController];
        }
    });
}




//
//+ (void)openMePath:(NSString *)path params:(NSDictionary *)params
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self canShowViewController]) {
//
//            DJMainTabBarController *mainViewController = [DJAppCall clearAllPresentViewController];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [mainViewController gotoMeViewController];
//            });
//        }
//    });
//}
//
//+(DJMainTabBarController *)clearAllPresentViewController
//{
//    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//    DJMainTabBarController *mainViewController = (DJMainTabBarController *)window.rootViewController;
//    if ([mainViewController.selectedViewController isKindOfClass:[UINavigationController class]]) {
//        UINavigationController *navigationController = (UINavigationController *)mainViewController.selectedViewController;
//        [navigationController popToRootViewControllerAnimated:NO];
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [mainViewController dismissViewControllerAnimated:YES completion:nil];
//    });
//    return mainViewController;
//}
//
+ (void)openFittingRoomWithPath:(NSString *)path params:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            FittingRoomViewController *controller = [[FittingRoomViewController alloc] init];
            [self showViewController:controller];
            [controller setEnterCondition:nil filters:nil];
        }
    });
}




+ (void)searchByPhoto:(NSString *)path params:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            AddClothByCameraViewController *controller = [[AddClothByCameraViewController alloc] init];
            [self showViewController:controller];
        }
    });
}

+ (void)searchClothes:(NSString *)path params:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            SearchClothesViewController *controller = [[SearchClothesViewController alloc] init];
            [self showViewController:controller];
        }
    });
}


//+ (void)itemsYouMayOwn:(NSString *)path params:(NSDictionary *)params
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self canShowViewController]) {
//            RecommendationViewController *controller = [[RecommendationViewController alloc] init];
//            [self showViewController:controller];
//        }
//    });
//}


//+ (void)findClothes:(NSString *)path params:(NSDictionary *)params
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self canShowViewController]) {
//            CategoryFindViewController *controller = [[CategoryFindViewController alloc] initWithBeginCategoryId:nil];
//            [self showViewController:controller];
//        }
//    });
//}

+ (void)findStyles:(NSString *)path params:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            StyleViewController *controller = [[StyleViewController alloc] initWithURLString:[[ConfigDataContainer sharedInstance] getOutfitsUrl]];
            [self showViewController:controller];
        }
    });
}

+ (void)newConversation:(NSString *)path params:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            [[DJUserFeedbackLogic instance] showConversation];
        }
    });
}

+ (void)conversationList:(NSString *)path params:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canShowViewController]) {
            [[DJUserFeedbackLogic instance] showConversationList];
        }
    });
}


//
//+ (void)openTryOnWithPath:(NSString *)path params:(NSDictionary *)params
//{
//    NSArray *idsStr = [path componentsSeparatedByString:@","];
//    NSMutableArray *idsNumber = [NSMutableArray new];
//    for (NSString *pid in idsStr) {
//        [idsNumber addObject:@((UInt64)pid.longLongValue)];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self canShowViewController]) {
//        }
//    });
//}
//
//+ (void)openProfileWithPath:(NSString *)path params:(NSDictionary *)params
//{
//    UInt64 userid = (UInt64)[path longLongValue];
//    if (!userid) {
//        return;
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self canShowViewController]) {
//        }
//    });
//}

//+(void)openWebViewController:(NSString *)url
//{
//    if (!url) {
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self canShowViewController]) {
//            DJWebViewController *webViewController = [[DJWebViewController alloc] initWithURLString:url];
//            webViewController.hidesBottomBarWhenPushed = YES;
//            [self showViewController:webViewController];
//        }
//    });
//}

+ (BOOL)canShowViewController
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (![window.rootViewController isKindOfClass:[UITabBarController class]]) {
        return NO;
    }
    return YES;
}

+ (void)showViewController:(UIViewController *)viewController
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UITabBarController *mainViewController = (UITabBarController *)window.rootViewController;
    [mainViewController dismissViewControllerAnimated:NO completion:nil];
    for (UIViewController *vc in mainViewController.viewControllers) {
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
    if ([mainViewController.selectedViewController isKindOfClass:[UINavigationController class]]) {
        viewController.hidesBottomBarWhenPushed = true;
        [(UINavigationController *)mainViewController.selectedViewController pushViewController:viewController animated:YES];
    }
}

+ (NSString *)topViewControllName {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UITabBarController *mainViewController = (UITabBarController *)window.rootViewController;
    if ([mainViewController.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *vc = [(UINavigationController *)mainViewController.selectedViewController topViewController];
        if (vc) {
            return NSStringFromClass([vc class]);
        }
    }
    return @"";
}

@end
