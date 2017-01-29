//
//  MONumberUtil.m
//  DejaFashion
//
//  Created by Sun lin on 18/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "MONumberUtil.h"

@implementation MONumberUtil

+(UInt64) generateUniqueInt64Id
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    UInt64 d = time * 1000;
    UInt64 i =  ((d << 16) | ([self randomShort16] & 0x7fff));
    return i;
}

+(UInt16) randomShort16
{
    return rand() % (0xffff);
}
@end
