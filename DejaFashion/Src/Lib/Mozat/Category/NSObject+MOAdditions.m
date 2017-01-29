//
//  NSObject+MOAdditions.m
//  DejaFashion
//
//  Created by Sun lin on 18/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "NSObject+MOAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (MOAdditions)

static char UIB_PROPERTY_KEY;
@dynamic property;

-(void)setProperty:(NSObject *)property
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, property, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSObject*)property
{
    return (NSObject*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}


+ (NSArray *)propertyList
{
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(self, &outCount);
    for (int i=0; i<outCount; i++)
    {
        NSParameterAssert(properties);
        const char *name = property_getName(properties[i]);
        [array addObject:[NSString stringWithFormat:@"%s", name]];
    }
    if (properties)
    {
        free(properties);
    }
    return [NSArray arrayWithArray:array];
}

+ (NSDictionary *)refinedDictionaryDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = [self propertyList];
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    NSMutableArray *keysToRemove = [NSMutableArray array];
    for (NSString *key in mutableDict.allKeys)
    {
        BOOL exist = NO;
        for (NSString *col in keys)
        {
            if ([key isEqualToString:col])
            {
                exist = YES;
                break;
            }
        }
        if (!exist)
        {
            [keysToRemove addObject:key];
        }
    }
    
    [mutableDict removeObjectsForKeys:keysToRemove];
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

@end
