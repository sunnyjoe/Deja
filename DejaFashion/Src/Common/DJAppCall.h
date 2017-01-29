//
//  DJAppCall.h
//  DejaFashion
//
//  Created by Kevin Lin on 6/1/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJAppCall : NSObject

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
+ (NSDictionary *)dictionaryWithQuery:(NSString *)query;

+ (NSString *)topViewControllName;
@end
