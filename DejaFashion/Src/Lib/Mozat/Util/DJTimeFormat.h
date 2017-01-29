//
//  DJTimeFormat.h
//  DejaFashion
//
//  Created by DanyChen on 8/6/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJTimeFormat : NSObject

+(NSString *)formatWithTimeIntervalSince1970: (UInt64)seconds;

@end
