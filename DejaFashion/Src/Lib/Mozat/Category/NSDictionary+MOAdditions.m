//
//  NSDictionary+MOAdditions.m
//  DejaFashion
//
//  Created by Sun lin on 24/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "NSDictionary+MOAdditions.h"

@implementation NSDictionary (MOAdditions)

- (id)objectForIntegerKey:(NSInteger)aKey
{
    return [self objectForKey:[NSNumber numberWithInteger:aKey]];
}

@end
