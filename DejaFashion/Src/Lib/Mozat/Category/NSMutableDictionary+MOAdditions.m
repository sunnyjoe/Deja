//
//  NSMutableDictionary+MOAdditions.m
//  Mozat
//
//  Created by sunlin on 9/10/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "NSMutableDictionary+MOAdditions.h"

@implementation NSMutableDictionary (MOAdditions)

-(void)setInt:(int)aValue forKey:(id<NSCopying>)aKey{
	[self setObject:[NSNumber numberWithInt:aValue] forKey:aKey];
}

-(void)setBool:(BOOL)aValue forKey:(id<NSCopying>)aKey{
	[self setObject:[NSNumber numberWithInt:aValue] forKey:aKey];
}

-(void)setLongLong:(long)aValue forKey:(id<NSCopying>)aKey{
	[self setObject:[NSNumber numberWithLong:aValue] forKey:aKey];
}

-(void)setObject:(id)anObject forIntegerKey:(NSInteger)aKey
{
    [self setObject:anObject forKey:[NSNumber numberWithInteger:aKey]];
}

@end
