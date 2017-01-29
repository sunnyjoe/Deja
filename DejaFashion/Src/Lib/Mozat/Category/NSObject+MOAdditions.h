//
//  NSObject+MOAdditions.h
//  DejaFashion
//
//  Created by Sun lin on 18/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MOAdditions)

@property (nonatomic, retain) NSObject *property;

+ (NSArray<NSString *> *)propertyList;
+ (NSDictionary *)refinedDictionaryDictionary:(NSDictionary *)dictionary;

@end
