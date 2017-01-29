//
//  DJWebViewController.m
//  DejaFashion
//
//  Created by Sun lin on 10/4/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJWebViewController.h"
#import "Reachability.h"
#import "DJShareWindow.h"
#import "DJConfigDataContainer.h"
#import "DJShareLogNetTask.h"
#import "DJAppCall.h"
#import "DJSignInAlertView.h"
#import "MONetTaskQueue.h"
#import "DJConfigDataContainer.h"
#import "DJCopyURLShareEntry.h"
#import "DJReminderBannerView.h"
#import "DJUploadFileNetTask.h"
#import "NSURL+MOAdditions.h"
#import "DejaFashion-Swift.h"
#import "DJProductFilterView.h"
#import "LocationManager.h"
#import "DJWXShareEntry.h"
#import "DJWXChatEntry.h"
#import "DJWhatsappEntry.h"
#import "DJMessageEntry.h"
#import "MBProgressHUD+ShowText.h"
#import "MBProgressHUD.h"

@import SBJson4;

#define JS_JSON_DATA_FORMAT @"window.__dejafashion_data_%@ ? JSON.stringify(window.__dejafashion_data_%@) : ''"
#define JS_DATA_FORMAT @"window.__dejafashion_data_%@.%@"
#define OBSERVER_KEY_PROGRESS @"estimatedProgress"

#define kNotificationWebviewRecreated "kNotificationWebviewRecreated"

//@implementation ShareArgument
//@end

@interface DJWebViewController ()<MONetTaskDelegate, DJShareEntryDelegate, WKNavigationDelegate, WKUIDelegate, DJProductFilterViewDelegate, OccasionFilterViewDelegate, DJSignInAlertViewDelegate,StylingMissionCreatingDelegate>
@property(nonatomic, retain)  UIProgressView *progressView;

@property(nonatomic, retain) DJShareEntry *entry;
@property(nonatomic, retain) DJUploadFileNetTask *uploadFileNetTask;


@property(nonatomic, strong) OccasionFilterView *filterView;
@property(nonatomic, strong) DJProductFilterView *productFilterView;

@property(nonatomic, strong) NSArray<Filter *> *selectedFilter;

@property(nonatomic, weak) UIView *tutorialView;

@property(nonatomic, assign) BOOL isForeground;

@property(nonatomic, strong) WKBackForwardListItem *lastBackForwardListItem;

@property(nonatomic, copy) NSURL *lastOpenedUrl;

@property(nonatomic, assign) BOOL jumpToLogin;
@property(nonatomic, assign) BOOL viewStatedResetted;
@property(nonatomic, assign) BOOL stylingMissionCreated;
@property(nonatomic, assign) CLLocationCoordinate2D currentLocation;
@end


@implementation DJWebViewController

- (WKWebView *)webView {
    if (self.useSingleWebview) {
        if (_webView == nil) {
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        }
        return _webView;
    }
    
    if (self.isForeground) {
        if (!sharedWebView) {
            sharedWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
            sharedWebviewFinishloading = NO;
            self.lastBackForwardListItem = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationWebviewRecreated object:nil];
        }
        return sharedWebView;
    }
    return nil;
}

- (instancetype)initWithURLString:(NSString *)urlString
{
    self = [super init];

    if ([urlString containsString:@"dejafm"]) {
        urlString = [NSString stringWithFormat:@"%@&_native_t=%lld", urlString, [NSDate currentTimeMillis]];
    }
    
    if(self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

-(void)viewDidLoad
{
    if (!sharedWebView || !sharedWebviewFinishloading) {
        sharedWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationWebviewRecreated object:nil];
    }
    
    [super viewDidLoad];
    self.isForeground = YES;
    NSURLRequest *req = [NSURLRequest requestWithURL:self.url];
    //    self.title = req.URL.absoluteString;//lulu will change the title lately
    [self updateNavigationBarButton:nil];
    
    self.backBarButton = [UIBarButtonItem initWithImage:[UIImage imageNamed:@"WhiteBackIconNormal"] highlightedImage:nil target:self action:@selector(backBtnDidTap)];
//    self.closeBarButton = [[DJBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"WhiteCloseIcon"] highlightedImage:nil target:self action:@selector(closeBtnDidTap)];

    
    self.progressView = [UIProgressView new];
    self.progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 2);
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.alpha = 0.0;
    [self.webView loadRequest: req];
}

-(void)viewWillAppear:(BOOL)animated {
    self.viewStatedResetted = true;
    self.isForeground = YES;
    self.jumpToLogin = NO;
    [self.webView addObserver:self forKeyPath:OBSERVER_KEY_PROGRESS options:NSKeyValueObservingOptionNew context:nil];
    
    if (!self.useSingleWebview) {
        if (self.lastBackForwardListItem) {
            if (self.webView.backForwardList.currentItem != self.lastBackForwardListItem) {
                [self.webView goToBackForwardListItem:self.lastBackForwardListItem];
            }else {
                if (self.stylingMissionCreated) {
                    [self setAction:@"addMission" result:nil];
                }
            }
        }else if (self.lastOpenedUrl){
            [self.webView loadRequest:[NSURLRequest requestWithURL:self.lastOpenedUrl]];
        }
    }
    self.stylingMissionCreated = false;
//    for (WKBackForwardListItem *item in self.webView.backForwardList.backList) {
//        NSLog(@"item url = %@" , item.URL.description);
//    }
    
    [super viewWillAppear:animated];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.35), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.webView.alpha = 1.0;
        }];
    });

    [self.view addSubview:self.progressView];
    
    [self showHomeButton:true];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [DJAlertView alertViewWithTitle:MOLocalizedString(@"Network Unavailable", @"")
                                message:nil
                      cancelButtonTitle:MOLocalizedString(@"Dismiss", @"")
                      otherButtonTitles:nil onDismiss:^(int buttonIndex) {
                          
                      } onCancel:^{
                          [self goBack];
                      }];
        return;
    }
    
}

-(void)willMoveToParentViewController:(UIViewController *)parent{
    if(parent != nil){
        return;
    }
    [self clearViewState];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self clearViewState];
    [super viewWillDisappear:animated];
}

-(void)clearViewState{
    if (!self.viewStatedResetted) {
        return;
    }
    self.viewStatedResetted = false;
    
    if (!self.useSingleWebview) {
        self.lastBackForwardListItem = self.webView.backForwardList.currentItem;
        self.lastOpenedUrl = self.lastBackForwardListItem.URL;
    }
    if (!self.jumpToLogin) {
        if (self.webView.navigationDelegate == self) {
            self.webView.navigationDelegate = nil;
            self.webView.UIDelegate = nil;
            
            //        [self.webView reload];
            [self.webView removeFromSuperview];
        }
    }
    [self.webView removeObserver:self forKeyPath:OBSERVER_KEY_PROGRESS];
    self.isForeground = NO;
}

-(void)dealloc {
//    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[[ConfigDataContainer sharedInstance] getDejafmBlankUrl]]];
//    [sharedWebView loadRequest:req];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:OBSERVER_KEY_PROGRESS]) {
        if(self.webView.estimatedProgress == 1)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                self.progressView.hidden = YES;
            });
        }
        else
        {
            self.progressView.hidden = NO;
        }
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    }
}


-(void)updateNavigationBarButton:(NSString *)barText
{
    UIBarButtonItem *oneMore;
    if([barText isEqualToString:@"share"])
    {
        oneMore = [UIBarButtonItem initWithImage:[UIImage imageNamed:@"ShareIcon"]
                                        highlightedImage:[UIImage imageNamed:@"ShareIconPressed"]
                                                  target:self action:@selector(shareBtnDidTap)];
    }
    else if([barText isEqualToString:@"filter"]){
        oneMore = [UIBarButtonItem initWithImage:[UIImage imageNamed:@"FilterIcon"]
                                        highlightedImage:nil
                                                  target:self action:@selector(barBtnDidTap)];
        
    }
    else if([barText isEqualToString:@"add"]){
        oneMore = [UIBarButtonItem initWithImage:[UIImage imageNamed:@"WhiteAddIcon"]
                                        highlightedImage:nil
                                                  target:self action:@selector(barBtnDidTap)];
    }
    
    NSMutableArray *items = [NSMutableArray new];
    if(self.homeItem)
    {
        [items addObject:self.homeItem];
    }
    if (oneMore)
    {
        
        UIBarButtonItem *spacerBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                             target:nil
                                                                                             action:nil];
        spacerBarButtonItem.width = 15;
        [items addObject:spacerBarButtonItem];
        [items addObject:oneMore];
    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = items;
}

-(void)didChooseFilters:(NSArray<Filter *> *) filters{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSMutableArray *tags = [NSMutableArray new];
    if (filters.count) {
        for (int i = 0 ; i < filters.count; i++) {
            NSMutableDictionary *tag = [NSMutableDictionary new];
            [tag setValue:filters[i].id forKey:@"id"];
            [tag setValue:filters[i].name forKey:@"name"];
            [tag setValue:filters[i].condtionId forKey:@"conditionId"];
            [tags addObject:tag];
        }
    }
    [dic setObject:tags forKey:@"tags"];
    [StyleDataContainer sharedInstance].selectedStyleFilter = filters;
    [self setAction:@"styleFilter" result:dic];
}

#pragma end

-(void)backBtnDidTap
{
    if (self.productFilterView && !self.productFilterView.hidden) {
        self.productFilterView.hidden = true;
        return;
    }
    if (self.filterView && !self.filterView.hidden) {
        [self.filterView hideAnimation];
        return;
    }
    if ([self.webView.URL.absoluteString isEqualToString:self.url.absoluteString]) {
        [self closePage];
        return;
    }
    
    if([self.webView canGoBack])
    {
        [self.webView goBack];
        
        [self customLeftBarButtons];
    }
    else
    {
        [self closePage];
    }
}

-(void)goBack {
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
    }else {
        [super goBack];
    }
}

-(void)closeBtnDidTap
{
    [self closePage];
    [[DJStatisticsLogic instance] addTraceLog: [DJStatisticsKeys H5_Click_Close]];
}

-(void)closePage
{
    [self.webView evaluateJavaScript:@"!!window.__dejafashion_before_unload" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        BOOL result = ((NSNumber *)obj).boolValue;
        if(!result)
        {
            [self goBack];
        }
        else
        {
            [self.webView evaluateJavaScript:@"window.__dejafashion_before_unload()" completionHandler:nil];
        }
    }];
    if (!self.webView) {
        [self goBack];
    }
    
}

-(void)barBtnDidTap
{
    self.tutorialView.hidden = YES;
    [self fetchJSDataByActionName:@"updateBarButton" andKey:@"default" completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
        NSString *barText = obj;
        [self setAction:@"updateBarButton" result:@{@"default": barText}];
    }];
}

-(void)handleRenewMissionOutfit:(NSURLRequest *)request path:(NSString *)path
{
    
    [self handleRenewMissionOutfit:request path:path];
    
    NSString *oId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *desc = self.missionInfo[@"mission_desc"];
    NSString *name = self.missionInfo[@"user_name"];
    NSString *avatar = self.missionInfo[@"user_avatar"];
    OthersFittingRoomViewController *v = [[OthersFittingRoomViewController alloc] initWithMissionID:oId requirement:desc userName:name];
    v.avatarUrl = avatar;
    [self.navigationController pushViewController:v animated:YES];
    [self closeCurrentPage];
}

-(void)handleSubmitMissionOutfit:(NSURLRequest *)request path:(NSString *)path
{
    
    [MBProgressHUD showHUDAddedTo:self.view text:MOLocalizedString(@"Submit successfully!", @"") animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationMissionOutfitCreated object:nil userInfo:self.missionInfo];
        
        if (![ConfigDataContainer sharedInstance].pushPopupTipHasShown) {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate registerForAPN:@"Outfit is submitted!" withDesc:[NSString stringWithFormat:MOLocalizedString(@"Would you like to be alerted when %@ like your outfits?", @""), _missionInfo[@"user_name"] == nil ? @"she" : _missionInfo[@"user_name"]]];
            BOOL friendListInTheStack = false;
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if([vc isMemberOfClass:[FriendListViewController class]]) {
                    friendListInTheStack = true;
                    break;
                }
            }
            if (friendListInTheStack) {
                [self closePreviousPage];
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                [self closePreviousPage];
                [self.navigationController pushViewController:[FriendListViewController new] animated:YES];
                [self closeCurrentPage];
            }
        }else {
            [self closePreviousPage];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    });
    
}

-(BOOL)handleAddMission:(NSURLRequest *)request path:(NSString *)path{
    
    if ([[AccountDataContainer sharedInstance] isAnonymous]) {
        [[MONetTaskQueue instance] addTaskDelegate:self uri:[LoginNetTask uri]];
        [DJSignInAlertView alertSignInWithMessage:MOLocalizedString(@"Sign in to explore more of Deja", @"") loginSource: @"webview"delegate:self];
        return YES;
    }
    
    NSString *cid;
    NSString *oid;
    
    StylingMissionCreatingViewController *v = [StylingMissionCreatingViewController new];
    
    if (path.length > 0) {
        // ids=aaa,bbb&occasion=aaa,bbb
        NSString *idsStr = [path substringFromIndex:1];
        NSArray *array = [idsStr componentsSeparatedByString:@"&"];
        if (array.count) {
            for (NSString* s in array) {
                if ([s containsString:@"ids="]) {
                    NSString* idsArray = [s stringByReplacingOccurrencesOfString:@"ids=" withString:@""];
                    NSArray<NSString *> *ids = [idsArray componentsSeparatedByString:@","];
                    cid = ids.firstObject;
                }
                if ([s containsString:@"occasion="]) {
                    NSString* idsArray = [s stringByReplacingOccurrencesOfString:@"occasion=" withString:@""];
                    NSArray<NSString *> *ids = [idsArray componentsSeparatedByString:@","];
                    oid = ids.firstObject;
                }
            }
            
        }
    }
    if (cid.length) {
        v.clothesId = cid;
    }
    if (oid.length) {
        v.occasionId = oid;
    }
    v.delegate = self;
    [self.navigationController pushViewController:v animated:true];
    return NO;
}

-(void)handleTryOn:(NSURLRequest *)request path:(NSString *)path{
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [DJNetworkFailedTip showToast:self.view];
    }else {
        NSString *idsStr = [path substringFromIndex:1];
        NSArray *idsArray = [idsStr componentsSeparatedByString:@","];
        
        FittingRoomViewController *frVC = [FittingRoomViewController new];
        [self.navigationController pushViewController:frVC animated:true];
        if (self.filterView != nil) {
            [frVC setEnterCondition:idsArray filters:self.filterView.selectedFilters];
        }else{
            [frVC setEnterCondition:idsArray filters:nil];
        }
    }
}

-(void)handleStyleFilter:(NSURLRequest *)request path:(NSString *)path{
    BOOL guide = [path isEqualToString:@"/guide"];
    if(guide) {
        return;
    }

    if (!self.filterView) {
        NSArray *styleCondi = [[ConfigDataContainer sharedInstance] getConfigStyleCategory];
        NSMutableArray *array = [NSMutableArray new];
        for (FilterCondition *condition in styleCondi) {
            [array addObject:condition.id];
        }
        self.filterView = [[OccasionFilterView alloc] initWithFrame:self.view.bounds];
        self.filterView.hidden = YES;
        self.filterView.delegate = self;
        //        NSArray<Filter *> *filters = [StyleDataContainer sharedInstance].selectedStyleFilter;
        //        if (filters.count) {
        //            self.selectedFilter = filters;
        //        }
    }
    
    if (!self.filterView.hidden) {
        [self.filterView hideAnimation];
        return;
    }
    
    [self fetchJSDataByActionName:@"styleFilter" andKey:@"" completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
        if(!obj)
        {
            return;
        }
        NSData *jsonData = [obj dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        NSMutableArray<Filter *> *filters = [[NSMutableArray<Filter *> alloc]init];
        if ([obj isMemberOfClass:[NSNull class]]) {
            return ;
        }
        NSArray *jsonArray = json[@"tags"];
        if (jsonArray.count) {
            for (NSDictionary *dic in jsonArray) {
                Filter *filter = [Filter new];
                filter.id = dic[@"id"];
                filter.name = dic[@"name"];
                filter.condtionId = dic[@"conditionId"];
                [filters addObject:filter];
            }
        }
        self.selectedFilter = filters;
        [self.filterView resetSelectedFilters:self.selectedFilter];
        
        [self.view addSubview:self.filterView];
        [self.filterView showAnimation];
    }];
}

-(void)handlePriceFilter{
    if (!self.productFilterView) {
        self.productFilterView = [[DJProductFilterView alloc] initWithFrame:self.view.bounds];
        self.productFilterView.hidden = YES;
        self.productFilterView.delegate = self;
    }
    [self.view addSubview:self.productFilterView];
    if (self.productFilterView.hidden) {
        self.productFilterView.backgroundColor = [UIColor clearColor];
        self.productFilterView.hidden = NO;
        self.productFilterView.frame = CGRectMake(0, -260, self.view.frame.size.width, self.view.frame.size.height + 260);
        [UIView animateWithDuration:0.3 animations:^{
            self.productFilterView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 260);
            self.productFilterView.backgroundColor = [DJCommonStyle backgroundColorWithAlpha:0.75];
        } completion:^(BOOL finished) {
            
        }];
        
        
    }else {
        self.productFilterView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 260);
        [UIView animateWithDuration:0.3 animations:^{
            self.productFilterView.frame = CGRectMake(0, -260, self.view.frame.size.width, self.view.frame.size.height + 260);
            self.productFilterView.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            self.productFilterView.hidden = YES;
        }];
    }
}


-(void)productFilterBackgroundDidClick:(DJProductFilterView *)view {
    self.productFilterView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 260);
    [UIView animateWithDuration:0.3 animations:^{
        self.productFilterView.frame = CGRectMake(0, -260, self.view.frame.size.width, self.view.frame.size.height + 260);
        self.productFilterView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        self.productFilterView.hidden = YES;
        
    }];
}

-(void)productFilterViewDone:(DJProductFilterView *)view {
    self.productFilterView.hidden = true;
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:@(view.lowerPrice * 100) forKey:@"fromPrice"];
    [dic setObject:@(view.higherPrice * 100) forKey:@"toPrice"];
    [dic setObject:@(view.searchStatus) forKey:@"status"];
    
    [self setAction:@"productFilter" result:dic];
}

-(void)refineViewDone:(OccasionFilterView *)refineView {
    //{tags:[{id:tagId1,name:tagName1},{id:tagId2,name:tagName2}]}
//    [[DJStatisticsLogic instance] addTraceLog: [DJStatisticsKeys kStatisticsID_outfit_occasion_filter_done]];
    self.selectedFilter = refineView.selectedFilters;
    [self.filterView hideAnimation];
    [self didChooseFilters:refineView.selectedFilters];
}

#pragma DJShareEntryDelegate
-(void)sharedCompleted:(BOOL)success{
}

-(NSDictionary *)userInfo
{
    NSMutableDictionary *userinfo = [NSMutableDictionary new];
    [userinfo setObject:[AccountDataContainer sharedInstance].userID ? : @"" forKey:@"userid"];
    [userinfo setObject:[AccountDataContainer sharedInstance].userName ? : @"" forKey:@"name"];
    [userinfo setObject:[AccountDataContainer sharedInstance].avatar ? : @"" forKey:@"avatarUrl"];
    [userinfo setObject:[AccountDataContainer sharedInstance].signature ? : @"" forKey:@"sig"];
    [userinfo setObject:[AccountDataContainer sharedInstance].cartId ? : @"" forKey:@"cart_id"];
    
    return userinfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)fetchJSDataByActionName:(NSString *)actName andKey:(NSString *)key  completionHandler:(void (^ __nullable)(__nullable id obj, NSError * __nullable error))completionHandler
{
    NSString *script = nil;
    if(key.length > 0)
    {
        script = [NSString stringWithFormat:JS_DATA_FORMAT, actName, key];
    }
    else
    {
        script = [NSString stringWithFormat:JS_JSON_DATA_FORMAT, actName, actName];
    }
    [self.webView evaluateJavaScript:script completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        if([obj isMemberOfClass:[NSNull class]])
        {
            completionHandler(nil, error);
        }
        else
        {
            completionHandler(obj, error);
        }
    }];
}

-(void)setAction:(NSString *)actName result:(NSDictionary *)result
{
    NSString *script = [NSString stringWithFormat:@"window.__dejafashion_after_%@(%@)",actName, result ? result.JSONRepresentation : @""];
    [self.webView evaluateJavaScript:script completionHandler:nil];
}

- (void)handleImageBrowser{
    NSMutableDictionary *indexInfo = [NSMutableDictionary new];
    [indexInfo setObject:@2 forKey:@"index"];
     [self setAction:@"imageSlider" result:indexInfo];
}

- (void)handleLoginSuccess:(NSURLRequest *)request
{
    [self setAction:@"login" result:[self userInfo]];
    [MBProgressHUD hideHUDForView:[self view] animated:YES];
}

- (void)handleLoginFail:(NSURLRequest *)request
{
    [self setAction:@"login" result:nil];
    [MBProgressHUD hideHUDForView:[self view] animated:YES];
}


- (void)handleUserTraceLog:(NSString *)eventId
{
    
}

- (void)handleStatistics:(NSURLRequest *)request
{
    NSDictionary *params = [DJAppCall dictionaryWithQuery:request.URL.query];
    NSString *eventID = [params objectForKey:@"act"];
    if (eventID)
    {
        [self handleUserTraceLog:eventID];
        [[DJStatisticsLogic instance] addTraceLog:eventID];
    }
}

- (void)handleUserInfo:(NSURLRequest *)request
{
    [self setAction:request.URL.host result:[self userInfo]];
}


- (void)handleUDismissPhotoBrowser:(NSNumber *)index
{
    NSMutableDictionary *indexInfo = [NSMutableDictionary new];
    [indexInfo setObject:index forKey:@"index"];
    [self setAction:@"imageSlider" result:indexInfo];
}

- (void)handleUpdateBarButton:(NSURLRequest *)request
{
    [self fetchJSDataByActionName:request.URL.host andKey:@"default" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSString *barText = obj;
        [self updateNavigationBarButton:barText];
    }];
}

- (void)handleCopy:(NSURLRequest *)request
{
    [self fetchJSDataByActionName:request.URL.host andKey:@"default" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSString *copyText = obj;
        UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
        [gpBoard setString:copyText];
        [self setAction:request.URL.host result:nil];
    }];
}

- (void)handleVoteOver:(NSURLRequest *)request
{
    [self setAction:request.URL.host result:nil];
    [self goBack];
}

- (void)handleModifyTitle:(NSURLRequest *)request
{
    
    [self fetchJSDataByActionName:request.URL.host andKey:@"default" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSString *title = obj;
        if(title.length > 0 && ![self.title isEqualToString:title])
        {
            self.title = title;
        }
        [self customLeftBarButtons];
        [self setAction:request.URL.host result:nil];
    }];
}

- (void)handleLogin:(NSURLRequest *)request
{
    //dejafashion://login/[?plf=facebook|google|twitter][&onymous=0|1]
    NSString *uid = [AccountDataContainer sharedInstance].userID;
//    NSString *sig = [AccountDataContainer sharedInstance].signature;
    
    BOOL sigExpired = [request.URL queryItemForKey:@"expired"].value.integerValue != 0;
    
    if (sigExpired) {
        [MBProgressHUD showHUDAddedTo:self.view text:MOLocalizedString(@"Sorry, your login status expired.", @"") animated:YES];
        [self sigExpired];
        return;
    }
    
    BOOL forceLogin = [request.URL queryItemForKey:@"anonymous"].value.integerValue == 0;
    if (forceLogin) {
        if (![[AccountDataContainer sharedInstance] isAnonymous]) {
            [self iFrameLogic];
        }else {
            [[MONetTaskQueue instance] addTaskDelegate:self uri:[LoginNetTask uri]];
//            [DJSignInAlertView alertSignInWithMessage:MOLocalizedString(@"Sign in to explore more of Deja", @"") loginSource: @"webview"delegate:self];
            
            self.jumpToLogin = YES;
            [self.navigationController pushViewController:[LoginViewController new] animated:YES];
        }
    }else {
        if (uid.length) {
            [self iFrameLogic];
        }
    }
}

//-(void)signInAlertViewDidClickLogin {
//    self.jumpToLogin = YES;
//    [self.navigationController pushViewController:[LoginViewController new] animated:YES];
//}

- (void)handleSetBgColor:(NSURLRequest *)request
{
    NSString *action = request.URL.host;
    [self fetchJSDataByActionName:action andKey:@"default" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSString *colorValue = obj;
        [self.view setBackgroundColor:[UIColor colorFromHexString:colorValue]];
        [self setAction:action result:nil];
    }];
}



-(void)shareBtnDidTap
{
    [self handleShare:nil];
    
    NSString *url =  self.webView.URL.absoluteString;
    NSString *clothDetailUrl = [[ConfigDataContainer sharedInstance] getClothDetailUrl:@""];
    NSString *insiprationDetailUrl = [[ConfigDataContainer sharedInstance] getInspirationDetailUrl:@""];
    if ([url hasPrefix:clothDetailUrl])
    {
        [[DJStatisticsLogic instance] addTraceLog:DJStatisticsKeys.detail_click_share];
    }
    else if ([url hasPrefix:insiprationDetailUrl])
    {
        [[DJStatisticsLogic instance] addTraceLog:DJStatisticsKeys.Inspiration_Detail_Click_Share];
    }
}


-(void)handleShare:(NSURLRequest *)request
{
    NSString *action = @"share";
    if(request)
    {
        action = request.URL.host;
    }
    [self fetchJSDataByActionName:action andKey:nil completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
        if(!obj)
        {
            return;
        }
        ShareParameter *share = [self parseShareJson:obj error:error];
        if(share.link.length == 0)
        {
            share.link = request.URL.absoluteString;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
            hud.labelText = MOLocalizedString(@"Downloading image...", @"");
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                       {
                           BOOL shouldDownLoadImage = NO;
                           NSError *error=nil;
                           UIImage *thumbnail = nil;
                           NSData *data = nil;
//                           NSString *shortLink = nil;
                           if(share.thumbUrl.length > 0)
                           {
                               shouldDownLoadImage = YES;
                               NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:share.thumbUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
                               data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                               thumbnail = [UIImage imageWithData:data];
                               share.thumb = thumbnail;
//                               thumbnail = [UIImage resizeImageRetina:thumbnail size:CGSizeMake(200, 200 * thumbnail.size.height / thumbnail.size.width)];
//                               NSURL *shorlinkReqUrl = [NSURL urlWithFormat:@"%@/%@", DJServerBaseURL,@"apis_bm/config/get_short_url"];
//                               NSMutableURLRequest *shorlinkReq = [[NSMutableURLRequest alloc] initWithURL:shorlinkReqUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
//                               [shorlinkReq setHTTPMethod:@"POST"];
//                               [shorlinkReq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//                               [shorlinkReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//                               NSDictionary *body = @{@"url":share.link};
//                               NSData *requestData = [[body JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
//                               [shorlinkReq setHTTPBody:requestData];
//                               data = [NSURLConnection sendSynchronousRequest:shorlinkReq returningResponse:nil error:&error];
//                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//                               shortLink = [json objectForKey:@"data"];
//                               if (![shortLink hasPrefix:@"http://"])
//                               {
//                                   shortLink = [NSString stringWithFormat:@"http://%@", shortLink];
//                               }
//                               share.shortLink = share.link;
                               
                           }
                           
                           if((data && data.length && thumbnail && !error) || !shouldDownLoadImage)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   [MBProgressHUD hideHUDForView:[self view] animated:YES];
                                   
                                   if(request && request.URL.path.length > 0)
                                   {
                                       NSString *path = request.URL.path;
                                       if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
                                           [DJAlertView alertViewWithTitle:MOLocalizedString(@"No Internet Connection", @"") message:MOLocalizedString(@"Turn on cellular data or use Wi-Fi to access data.", @"") cancelButtonTitle:MOLocalizedString(@"OK", @"")];
                                           return;
                                       }
                                       
                                       if([path isEqualToString:@"/facebook"])
                                       {
                                           self.entry = [DJFBShareEntry new];
//                                           self.entry.contentText = share.text;
                                       }
                                       else if ([path isEqualToString:@"/twitter"])
                                       {
                                           self.entry = [DJTwitterShareEntry new];
//                                           self.entry.contentText = share.text;
                                       }
                                       else if([path isEqualToString:@"/instagram"])
                                       {
                                           self.entry = [DJInstagramShareEntry new];
//                                           self.entry.contentText = share.summary;
                                           
                                       }
                                       
//                                       self.entry.thumbnail = thumbnail;
//                                       self.entry.link = share.link;
//                                       self.entry.title = share.title;
//                                       self.entry.summary = share.summary;
//                                       self.entry.contentText = share.text;
//                                       self.entry.thumbUrl = share.thumbUrl;
//                                       self.entry.imageUrl = share.imageurl;
                                       self.entry.parameter = share;
                                       [self.entry share];
                                       
//                                       DJShareLogNetTask *shareLogNetTask = [DJShareLogNetTask new];
//                                       shareLogNetTask.type = DJShareLogWeb;
//                                       [[MONetTaskQueue instance] addTask:shareLogNetTask];
//                                       [[MONetTaskQueue instance] addTaskDelegate:self uri:shareLogNetTask.uri];
                                   }
                                   else
                                   {
                                       
                                       DJFBShareEntry *fbEntry = [DJFBShareEntry new];
                                       fbEntry.delegate = self;
                                       
                                       [DJShareWindow shareWithAugment:share
                                                                 entries:@[ fbEntry, [DJMessageEntry new], [DJWhatsappEntry new], [DJWXChatEntry new], [DJWXShareEntry new], [DJCopyURLShareEntry new] ]
                                                    showInViewController:self
                                                              completion:^(DJShareEntry *entry)  {
                                                                  if (entry == fbEntry)
                                                                  {
                                                                      [[DJStatisticsLogic instance] addTraceLog:DJStatisticsKeys.sharevia_click_FB];
                                                                  }
                                                              }];
                                   }
                                   if(request)
                                   {
                                       [self setAction:action result:nil];
                                   }
                                   
                               });
                           }
                           else
                           {
                               [MBProgressHUD hideHUDForView:[self view] animated:YES];
                               [DJAlertView alertViewWithTitle:MOLocalizedString(@"Sorry, failed to download image. Please try again later.", @"") message:nil
                                             cancelButtonTitle:MOLocalizedString(@"Ok", @"")];
                           }
                       });
        
    }];
}

-(ShareParameter *)parseShareJson:(id)obj error:(NSError *)er
{
    NSData *jsonData = [obj dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&er];
    ShareParameter *result = [ShareParameter new];
//    result.title = [json objectForKey:@"title"];
//    result.summary = [json objectForKey:@"summary"];
//    result.text = [json objectForKey:@"text"];
    result.imageUrl = [json objectForKey:@"imageurl"];
    result.thumbUrl = [json objectForKey:@"thumburl"];
    result.link = [json objectForKey:@"link"];
//    result.placeholder = json;
    result.source = [json objectForKey:@"source"];
    
    
    ShareTextConfig *config = [[ConfigDataContainer sharedInstance] getShareTextConfig];
    ShareSource *source = [config sourceForId:result.source] ;
//    source = nil;
    if (source == nil)
    {
        source = [config sourceForId:@"default"];
    }
    result.facebookTitle = source.facebook.title;
    result.facebookText = source.facebook.text;
    
    result.wechatTitle = source.wechat.title;
    result.wechatText = source.wechat.text;
    
    result.messageTitle = source.message.title;
    result.messageText = source.message.text;
    
    result.whatsappTitle = source.whatsapp.title;
    result.whatsappText = source.whatsapp.text;
    
    result.momentsTitle = source.moments.title;
    result.momentsText = source.moments.text;
    
    for(NSString  *key in json.keyEnumerator)
    {
        NSString *ph = [NSString stringWithFormat:@"${%@}", key];
        NSRange range = [result.facebookTitle rangeOfString:ph];
        if (range.length != 0)
        {
            result.facebookTitle = [result.facebookTitle stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.wechatTitle rangeOfString:ph];
        if (range.length != 0)
        {
            result.wechatTitle = [result.wechatTitle stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.messageTitle rangeOfString:ph];
        if (range.length != 0)
        {
            result.messageTitle = [result.messageTitle stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.whatsappTitle rangeOfString:ph];
        if (range.length != 0)
        {
            result.whatsappTitle = [result.whatsappTitle stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.momentsTitle rangeOfString:ph];
        if (range.length != 0)
        {
            result.momentsTitle = [result.momentsTitle stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        
        
        
        range = [result.facebookText rangeOfString:ph];
        if (range.length != 0)
        {
            result.facebookText = [result.facebookText stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.wechatText rangeOfString:ph];
        if (range.length != 0)
        {
            result.wechatText = [result.wechatText stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.messageText rangeOfString:ph];
        if (range.length != 0)
        {
            result.messageText = [result.messageText stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.whatsappText rangeOfString:ph];
        if (range.length != 0)
        {
            result.whatsappText = [result.whatsappText stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
        range = [result.momentsText rangeOfString:ph];
        if (range.length != 0)
        {
            result.momentsText = [result.momentsText stringByReplacingCharactersInRange:range withString:[json objectForKey:key]];
        }
    }
    

    return result;
}

- (void)handleCloseWeb:(NSURLRequest *)request
{
    [self goBack];
    [self setAction:request.URL.host result:nil];
}

- (void)handleComment:(NSURLRequest *)request path:(NSString *)path
{
}


-(void)updateCurrentAddress
{
    CLLocationCoordinate2D coordinate = [[[LocationManager sharedInstance] currentLocation] coordinate];
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_LOCATION_UPDATE object:nil];
        [[LocationManager sharedInstance] geocodeAddress:(coordinate) completionHandler:^(Place *place, bool successed) {
            NSDictionary *result = nil;
            if (successed) {
                result = [NSDictionary dictionaryWithObject:place.address forKey:@"address"];
            }
            else
            {
                result = [NSDictionary dictionaryWithObject:@"" forKey:@"address"];
            }
            [self setAction:@"userCurrentAddress" result:result];
        }];
    }
}

-(void)updateCurrentCoordinate
{
    CLLocationCoordinate2D coordinate = [[[LocationManager sharedInstance] currentLocation] coordinate];
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_LOCATION_UPDATE object:nil];
        NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                                @(coordinate.latitude), @"latitude",
                                @(coordinate.longitude), @"longitude",
                                nil];
        [self setAction:@"geolocation" result:result];
    }
}

-(void)updateCurrentCoordinateAuthDenied
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_LOCATION_AUTH_DENIED object:nil];
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(0), @"latitude",
                            @(0), @"longitude",
                            nil];
    [self setAction:@"geolocation" result:result];
}

-(void)updateCurrentAddressAuthDenied
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_LOCATION_AUTH_DENIED object:nil];
    NSDictionary *result = [NSDictionary dictionaryWithObject:@"" forKey:@"address"];
    [self setAction:@"userCurrentAddress" result:result];
}

-(void)handleUserGeoLocaiton
{
    
    if ([[LocationManager sharedInstance] enableServices])
    {
        [[LocationManager sharedInstance] startAccurateMonitor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentCoordinate) name:NOTIFY_LOCATION_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentCoordinateAuthDenied) name:NOTIFY_LOCATION_AUTH_DENIED object:nil];
    }
    else
    {
        [self updateCurrentCoordinateAuthDenied];
    }
}

-(void)handleUserCurrentAddress
{
    if ([[LocationManager sharedInstance] enableServices])
    {
        [[LocationManager sharedInstance] startAccurateMonitor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentAddress) name:NOTIFY_LOCATION_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentAddressAuthDenied) name:NOTIFY_LOCATION_AUTH_DENIED object:nil];
    }
    else
    {
        [self updateCurrentAddressAuthDenied];
    }
}


-(void)handleEnableNotification:(NSURLRequest *)request path:(NSString *)path
{
//    dealAlert

    
//    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
//        let n = self.name == nil ? "she" : self.name!
//        appDelegate.registerForAPN()
//    }

    
    if (![DJConfigDataContainer instance].hasPromoDealAlertRequestPermission)
    {
        Dialog *dialog = [Dialog new];
        [dialog withIcon:[UIImage imageNamed:@"NotificationIcon"]];
        [dialog withText:MOLocalizedString(@"You can turn on the notification and receive a deal alert when there is a discount of this item.", @"")];
        [dialog withOkBtnText:@"Got it!"];
        [dialog withCancelBtnText:nil];
        
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        [dialog show:^{
        } didClickCancel:^{
        } didDismiss:^{
            [DJConfigDataContainer instance].hasPromoDealAlertRequestPermission = true;
            [app registerForAPN];
        }];
    }
}

- (void)handleUploadImage:(NSURLRequest *)request path:(NSString *)path
{
    NSString *action = request.URL.host;
    [self fetchJSDataByActionName:action andKey:nil completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
        
        NSData *jsonData = [obj dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        NSString *type = [json objectForKey:@"action"];
        CGFloat width = ((NSNumber *)[json objectForKey:@"width"]).floatValue;
        NSString *format = [json objectForKey:@"type"];
        void (^onPhotoPicked)(UIImage *) = ^(UIImage *chosenImage) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
            hud.labelText = MOLocalizedString(@"Uploading image...", @"");
            UIImage *resizedImage = chosenImage;
            if(width > 0 && width < chosenImage.size.width)
            {
                CGSize targetSize = CGSizeMake(width, width * chosenImage.size.height / chosenImage.size.width);
                resizedImage = [UIImage resizeImageRetina:chosenImage size:targetSize];
            }
            NSData *imageData = nil;
            if([format isEqualToString:@"png"])
            {
                imageData = UIImagePNGRepresentation(resizedImage);
            }
            else
            {
                imageData = UIImageJPEGRepresentation(resizedImage, 80);
            }
            self.uploadFileNetTask = [DJUploadFileNetTask new];
            self.uploadFileNetTask.data = imageData;
            [[MONetTaskQueue instance] addTaskDelegate:self uri:self.uploadFileNetTask.uri];
            [[MONetTaskQueue instance] addTask:self.uploadFileNetTask];
        };
        
        if( [type isEqualToString:@"camera"])
        {
            [UIActionSheet pickPhotoFromCamera:self.view presentVC:self onPhotoPicked:onPhotoPicked onCancel:nil];
        }
        else if( [type isEqualToString:@"album"])
        {
            [UIActionSheet pickPhotoFromAlbum:self.view presentVC:self onPhotoPicked:onPhotoPicked onCancel:nil];
        }
        else
        {
            [UIActionSheet photoPickerWithTitle:nil showInView:self.view presentVC:self onPhotoPicked:onPhotoPicked onCancel:nil];
        }
        
    }];
    
    
}

#pragma end


- (void)handleUpdateProfile:(NSString *)action path:(NSString *)path
{
    if(path.length > 0)
    {
        if([path isEqualToString:@"/wardrobe"])
        {
            [[WardrobeSyncLogic sharedInstance] triggerSync];
            [DJConfigDataContainer instance].newWardrobeCount += 1;
        }
        if([path isEqualToString:@"/favourite"])
        {
            [DJConfigDataContainer instance].newFavouriteCount += 1;
        }
    }
    else
    {
    }
}

- (void)handleSaveBfcId:(NSURLRequest *)request
{
}

- (void)handleImageBroswer:(NSURLRequest *)request{
//    NSArray *hostHDImageUrls = [NSArray arrayWithObjects:@"http://www.planwallpaper.com/static/images/4-Nature-Wallpapers-2014-1_ukaavUI.jpg", @"https://static.pexels.com/photos/1029/landscape-mountains-nature-clouds.jpg", @"http://www.planwallpaper.com/static/images/4-Nature-Wallpapers-2014-1_ukaavUI.jpg", nil];
//    
    
    NSString *action = request.URL.host;
    [self fetchJSDataByActionName:action andKey:nil completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
        NSData *jsonData = [obj dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        NSNumber *index = [json objectForKey:@"index"];
        NSArray *hostHDImageUrls = [json objectForKey:@"list"];
        PhotoBrowser *photoB = [[PhotoBrowser alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [photoB resetDimissSelector:self sel:@selector(handleUDismissPhotoBrowser:)];
        [photoB showPhotoBrowser:self imageUrls:hostHDImageUrls index:index.integerValue];
    }];
}

- (void)handleSaveCartId:(NSURLRequest *)request
{
    [self fetchJSDataByActionName:request.URL.host andKey:@"default" completionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
        NSString *cartId = obj;
        [AccountDataContainer sharedInstance].cartId = cartId;
    }];
}


#pragma DJLogicSetDelegate
-(void)receiveAwardScore:(float)awardScore{
    DJReminderBannerView *awardBannerView = [[DJReminderBannerView alloc] initWithFrame:CGRectMake(0, -30, self.view.bounds.size.width, 30)];
    [self.view addSubview:awardBannerView];
    awardBannerView.labelStr = [NSString stringWithFormat:MOLocalizedString(@"Congratulations! You earned %.0f credit points!", @""), awardScore];
    [awardBannerView bannerAnimationDownUp];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [awardBannerView removeFromSuperview];
    });
}

#pragma mark - WKNavigationDelegate

-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:MOLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        //textField.placeholder = defaultText;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:MOLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:MOLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:MOLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}



- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    [self customLeftBarButtons];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    //    [self.progressView setProgress:0.0 animated:NO];
    if (!self.useSingleWebview) {
        sharedWebviewFinishloading = YES;
    }else {
        NSString *title = webView.title;
        if (title.length) {
            self.title = title;
        }else {
            self.title = MOLocalizedString(@"Details", @"");
        }
    }
    [self customLeftBarButtons];

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    UIApplication *app = [UIApplication sharedApplication];
    if ([url.scheme isEqualToString:@"tel"])
    {
        if ([app canOpenURL:url])
        {
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    BOOL isHandle = [self handleWebViewActionRequest:navigationAction.request];
    if(isHandle)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyAllow);
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable && ![self.url.absoluteString isEqualToString:navigationAction.request.URL.absoluteString]) {
            [DJNetworkFailedTip showToast:self.view];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

-(BOOL)handleWebViewActionRequest:(NSURLRequest *)request
{
    NSURL* url = request.URL;
    NSString *host = url.host;
    
    if ([url isiTunesURL]) {
        // This is for iTunes
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    
    
    if([url.absoluteString isEqualToString:[NSString stringWithFormat:@"%@/apis_bm/account/jump_success/v4", DJWebPageBaseURL]])
    {
        [self handleLoginSuccess:request];
    }
    
    if([url.absoluteString isEqualToString:[NSString stringWithFormat:@"%@/apis_bm/account/jump_fail/v4", DJWebPageBaseURL]])
    {
        [self handleLoginFail:request];
    }
    
    if([url.host isEqualToString:DJWebPageDomain] && [url.path hasSuffix:@"/analytics.html"])
    {
        [self handleStatistics:request];
    }
    
    // look for our custom action to come through:
    if(![url.scheme isEqualToString: @"dejafashion"])
    {
        return NO;
    }
    
    if ([host isEqualToString: @"userInfo"])
    {
        [self handleUserInfo:request];
    }
    
    else if ([host isEqualToString: @"updateBarButton"] )
    {
        [self handleUpdateBarButton:request];
    }
    
    else if ([host isEqualToString: @"copy"] )
    {
        [self handleCopy:request];
    }
    else if ([host isEqualToString: @"voteOver"] )
    {
        [self handleVoteOver:request];
    }
    
    else if ([host isEqualToString: @"modifytitle"] )
    {
        [self handleModifyTitle:request];
    }
    else if ([host isEqualToString: @"login"] )
    {
        [self handleLogin:request];
    }
    else if ([host isEqualToString: @"setBgColor"] )
    {
        [self handleSetBgColor:request];
    }
    else if ([host isEqualToString: @"share"] )
    {
        [self handleShare:request];
    }
    
    else if ([host isEqualToString: @"closeweb"] )
    {
        [self handleCloseWeb:request];
    }
    else if([host isEqualToString:@"saveBfcId"])
    {
        [self handleSaveBfcId:request];
    }
    else if([host isEqualToString:@"imageSlider"])
    {
        [self handleImageBroswer:request];
    }
    else if([host isEqualToString:@"saveCartId"])
    {
        [self handleSaveCartId:request];
    }
    else if([host isEqualToString:@"updateProfile"])
    {
        [self handleUpdateProfile:host path:url.path];
    }
    else if([host isEqualToString:@"creationComment"])
    {
        [self handleComment:request path:url.path];
    }
    else if([host isEqualToString:@"uploadImage"])
    {
        [self handleUploadImage:request path:url.path];
    }
    else if([host isEqualToString:@"styleFilter"])
    {
        [self handleStyleFilter:request path:url.path];
    }
    else if([host isEqualToString:@"productFilter"])
    {
        [self handlePriceFilter];
    }
    else if ([host isEqualToString: @"tryon"] )
    {
        [self handleTryOn:request path:url.path];
        
    }
    else if ([host isEqualToString:@"addMission"])
    {
        return [self handleAddMission:request path:url.path];
    }
    else if ([host isEqualToString:@"submitedMissionOutfit"])
    {
        [self handleSubmitMissionOutfit:request path:url.path];
    }
    else if ([host isEqualToString:@"renewMissionOutfit"])
    {
        [self handleRenewMissionOutfit:request path:url.path];
    }
    else if ([host isEqualToString:@"geolocation"])
    {
        [self handleUserGeoLocaiton];
    }else if ([host isEqualToString:@"userCurrentAddress"])
    {
        [self handleUserCurrentAddress];
    }
    else if ([host isEqualToString:@"enableNotification"])
    {
        [self handleEnableNotification:request path:url.path];
    }
    else
    {
        [DJAppCall handleOpenURL:request.URL sourceApplication:@"deja"];
        [self setAction:host result:nil];
        return NO;
    }
    return YES;
}

-(void)closeCurrentPage {
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if (self.navigationController.viewControllers[i] != self) {
            [array addObject:self.navigationController.viewControllers[i]];
        }
    }
    self.navigationController.viewControllers = array;
}

-(void)closePreviousPage {
    UInt64 index = [self.navigationController.viewControllers indexOfObject:self];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if (i != index - 1) {
            [array addObject:self.navigationController.viewControllers[i]];
        }
    }
    self.navigationController.viewControllers = array;
}

-(void)stylingMissionDidCreated {
    self.stylingMissionCreated = true;
}

-(void)sigExpired {
    [[WardrobeSyncLogic sharedInstance] clearUserData];
    [DJLoginLogic clearUserData];
    [AccountDataContainer sharedInstance].userID = nil;
    [AccountDataContainer sharedInstance].signature = nil;
    [AccountDataContainer sharedInstance].userName = nil;
    [AccountDataContainer sharedInstance].avatar = nil;
    [AccountDataContainer sharedInstance].cartId = nil;
    [[MONetTaskQueue instance] addTask:[RegisterNetTask new]];
    [self closePage];
    sharedWebView = nil;
}

-(void)iFrameLogic
{
    //    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    //    hud.labelText = MOLocalizedString(@"Loading", @"");
    NSString *token = [AccountDataContainer sharedInstance].signature;
    if(token.length)
    {
        NSString *script = [NSString stringWithFormat: @"(function(f,src){ f.setAttribute('style', 'display:none;width:0;height:0;position: absolute;top:0;left:0;border:0;'); f.setAttribute('id','__deja_login_frame'); f.setAttribute('height','0px'); f.setAttribute('width','0px'); f.setAttribute('frameborder','0'); f.setAttribute('src',src); document.documentElement.appendChild(f); })(document.createElement(\"iframe\"),'%@/apis_bm/account/jump/v4?uid=%@&sig=%@');", DJWebPageBaseURL, [AccountDataContainer sharedInstance].userID ,token];
        [self.webView evaluateJavaScript:script completionHandler:nil];
    }else {
        NSString *script = [NSString stringWithFormat: @"(function(f,src){ f.setAttribute('style', 'display:none;width:0;height:0;position: absolute;top:0;left:0;border:0;'); f.setAttribute('id','__deja_login_frame'); f.setAttribute('height','0px'); f.setAttribute('width','0px'); f.setAttribute('frameborder','0'); f.setAttribute('src',src); document.documentElement.appendChild(f); })(document.createElement(\"iframe\"),'%@/apis_bm/account/jump/v4?uid=%@');", DJWebPageBaseURL, [AccountDataContainer sharedInstance].userID];
        [self.webView evaluateJavaScript:script completionHandler:nil];
        
    }
}

- (void)customLeftBarButtons
{
    UIBarButtonItem *spacerBarButtonItem1 = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                 target:nil action:nil];
    UIBarButtonItem *spacerBarButtonItem2 = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                 target:nil action:nil];
    spacerBarButtonItem1.width = 0;
    spacerBarButtonItem2.width = 15;
    NSMutableArray *array = [NSMutableArray new];
    if([self leftBarButton1])
    {
        [array addObject:spacerBarButtonItem1];
        [array addObject:[self leftBarButton1]];
    }
    
    if([self leftBarButton2])
    {
        [array addObject:spacerBarButtonItem2];
        [array addObject:[self leftBarButton2]];
    }
    
    self.navigationItem.leftBarButtonItems = array;
}

-(UIBarButtonItem *)leftBarButton1
{
    return self.backBarButton;
}

-(UIBarButtonItem *)leftBarButton2
{
    if([self.webView canGoBack] && ![self.webView.URL.absoluteString isEqualToString:self.url.absoluteString])
    {
        return self.closeBarButton;
    }
    return nil;
}

- (void)netTaskDidEnd:(MONetTask *)task
{
    if([task isMemberOfClass:[LoginNetTask class]])
    {
        [self iFrameLogic];
    }
    
    if(task == self.uploadFileNetTask)
    {
        [MBProgressHUD hideHUDForView:[self view] animated:YES];
        NSString *imageUrl  = self.uploadFileNetTask.fileUrl;
        [self setAction:@"uploadImage" result:@{@"url": imageUrl}];
    }
    
}
- (void)netTaskDidFail:(MONetTask *)task
{
//    if([task isKindOfClass:[DJShareLogNetTask class]] || task == self.uploadFileNetTask)
//    {
//        [DJNetworkFailedTip showToast:self.view];
//    }
    if(task == self.uploadFileNetTask)
    {
        [DJNetworkFailedTip showToast:self.view];
    }
}

-(NSArray *)notificationNames {
    return @[@kNotificationWebviewRecreated];
}

-(void)didReceiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@kNotificationWebviewRecreated]) {
        self.lastBackForwardListItem = nil;
    }
}
@end
