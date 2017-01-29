//
//  DJUrl.h
//  DejaFashion
//
//  Created by Sun lin on 27/7/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kDJGoogleMapAppKey @"AIzaSyDzP_YdwR3d-6r-_joXk9iG2QcsGDALpvM"
#define kDJWechatAppKey @"wx4481bed8daf8c2cc"


#if APPSTORE
#define kDJHockeyappID @"b8f073824e4767ca2dc9d4ab22d6f4f7"
#define DJServerBaseURL @"http://api.dejafashion.com"
#define DJWebPageBaseURL @"http://m.deja.me"
#define DJWebPageDomain @"m.deja.me"
#define DJWebPageRC @""
#define DJServerImageStorage @"http://api.dejafashion.com/storage/"
#define kDJYouMengAppId @"56a0dbdb67e58ed1cd000020"


#elif PRODUCT
#define kDJHockeyappID @"cf0ab58d2082c145f740f58967ce541a"
#define DJServerBaseURL @"http://api.dejafashion.com"
#define DJWebPageBaseURL @"http://m.deja.me"
#define DJWebPageDomain @"m.deja.me"
#define DJWebPageRC @"_rc"
#define DJServerImageStorage @"http://api.dejafashion.com/storage/"
//#define kDJYouMengAppId @"5705dc76e0f55af62e0014ef"


#else
#define kDJHockeyappID @"2e9b209523daeff38f3b2462e054b49d"
#define DJServerBaseURL @"http://office.mozat.com:8081"
#define DJWebPageBaseURL @"http://office.mozat.com:8083"
#define DJWebPageDomain @"office.mozat.com"
#define DJWebPageRC @""
#define DJServerImageStorage @"http://office.mozat.com:8081/storage/"
#define kDJYouMengAppId @"5705dc76e0f55af62e0014ef"
#endif

#define kDJAppstoreId   @"971025031"
//#define kDJTalkingDataAppId @"7F965822B142B03ED997533C4F935A11"
//#define kDJFlurryAppId @"BPXCPG35P3G26KYGJQCJ"
#define kDJAdjustAppId @"i2x49mf1io74"
#define kDJAppsFlyerAppId @"NmsUpEqqFQkdHA3JqNFo97"
//#define kDJBugTagsAppId @"78f88d94d26ab1c106a7d588d551bd08"





@interface DJUrl : NSObject
+(NSString *)shareImageUrl;

@end
