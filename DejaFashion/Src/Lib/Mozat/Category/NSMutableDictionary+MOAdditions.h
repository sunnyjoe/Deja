//
//  NSMutableDictionary+MOAdditions.h
//  Mozat
//
//  Created by sunlin on 9/10/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (MOAdditions)


-(void)setInt:(int)aValue forKey:(id<NSCopying>)aKey;

-(void)setBool:(BOOL)aValue forKey:(id<NSCopying>)aKey;

-(void)setLongLong:(long)aValue forKey:(id<NSCopying>)aKey;

-(void)setObject:(id)anObject forIntegerKey:(NSInteger)aKey;


@end
