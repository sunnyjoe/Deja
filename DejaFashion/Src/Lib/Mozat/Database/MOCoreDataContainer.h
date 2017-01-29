//
//  MOCoreDataContainer.h
//  Mozat
//
//  Created by Kevin Lin on 29/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kDJProductRecentVersion     1
#define kDJProductFavouriteVersion  1


@interface MOCoreDataContainer : NSObject

- (void)setupWithCoordinator:(NSPersistentStoreCoordinator *)coordinator;
- (void)dropData;
- (void)didSetup;

- (BOOL)save;
- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly;
- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly predicate:(NSString *)predicate, ...;
- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly
                        sortBy:(NSString *)sortBy asce:(BOOL)asce
                     predicate:(NSString *)predicate, ...;
- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly
                        sortBy:(NSString *)sortBy asce:(BOOL)asce
                         limit:(NSInteger)limit predicate:(NSString *)predicate, ...;
- (void)removeObjectsForName:(NSString *)name;
- (void)removeObjectsForName:(NSString *)name predicate:(NSString *)predicate, ...;
- (int)countForName:(NSString *)name;
- (int)countForName:(NSString *)name predicate:(NSString *)predicate, ...;
- (id)insertObjectForName:(NSString *)name;
- (NSEntityDescription *)entityDescriptionForName:(NSString *)name;

@end
