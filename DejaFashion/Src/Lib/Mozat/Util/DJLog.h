//
//  DJLog.h
//  Mozat
//
//  Created by DuanDavid on 9/2/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DJ_SYSTEM @"DJ_SYSTEM"
#define DJ_NETWORK @"DJ_NETWORK"
#define DJ_DATABASE @"DJ_DATABASE"
#define DJ_UI @"DJ_UI"

@interface DJLog : NSObject

+ (void)info:(NSString *)module content:(NSString *)content, ...;
+ (void)error:(NSString *)module content:(NSString *)content, ...;
+ (void)warn:(NSString *)module content:(NSString *)content, ...;
+ (void)verbose:(NSString *)module content:(NSString *)content, ...;

@end
