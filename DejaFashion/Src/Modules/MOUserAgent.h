//
//  MOUserAgent.h
//  DejaFashion
//
//  Created by Sun lin on 22/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOUserAgent : NSObject

+ (instancetype)instance;
-(NSString*)userAgent;
-(NSString*)fullVersionString;
NSString* MOMD5HexString(NSString* str);
-(NSString*)deviceID;
@end
