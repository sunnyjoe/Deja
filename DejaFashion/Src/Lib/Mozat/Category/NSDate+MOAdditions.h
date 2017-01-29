//
//  NSDate+MOAdditions.h
//  DejaFashion
//
//  Created by Sun lin on 25/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MOAdditions)

+ (UInt64)currentTimeMillis;
+ (UInt64)currentTimeSecond;
//- (NSString*)formatShortTime;
//- (NSString*)formatTime;
- (NSString*)formatFullTime;
-(BOOL)pastMoreThanOneNaturalDay;
@end
