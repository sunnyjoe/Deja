//
//  MOCoreDataContainer.m
//  Mozat
//
//  Created by Kevin Lin on 29/10/14.
//  Copyright (c) 2014 MOZAT Pte Ltd. All rights reserved.
//

#import "MOCoreDataContainer.h"


@interface MOCoreDataContainer ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MOCoreDataContainer

- (void)setupWithCoordinator:(NSPersistentStoreCoordinator *)coordinator
{
    NSAssert(coordinator, @"'coordinator' should not be nil");
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.persistentStoreCoordinator = coordinator;
    [self didSetup];
}

- (void)dropData
{
    NSError *error = nil;
    for (NSPersistentStore *store in self.context.persistentStoreCoordinator.persistentStores) {
        [[NSFileManager defaultManager] removeItemAtURL:store.URL error:&error];
    }
    self.context = nil;
}

- (void)didSetup
{
}

- (BOOL)save
{
    if (![self.context hasChanges]) {
        return YES;
    }
    NSError *error;
    if (![self.context save:&error]) {
        return NO;
    }
    return YES;
}

- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly
{
    return [self getObjectsForName:name idOnly:idOnly predicate:nil];
}

- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly predicate:(NSString *)predicate, ...
{
    NSArray *objects = nil;
    if (predicate) {
        va_list args;
        va_start(args, predicate);
        objects = [self getObjectsForName:name idOnly:idOnly sortBy:nil asce:NO predicate:predicate arguments:args];
        va_end(args);
    }
    else {
        objects = [self getObjectsForName:name idOnly:idOnly sortBy:nil asce:NO predicate:nil arguments:nil];
    }
    return objects;
}

- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly
                        sortBy:(NSString *)sortBy asce:(BOOL)asce
                     predicate:(NSString *)predicate, ...
{
    NSArray *objects = nil;
    if (predicate) {
        va_list args;
        va_start(args, predicate);
        objects = [self getObjectsForName:name idOnly:idOnly sortBy:sortBy asce:asce predicate:predicate arguments:args];
        va_end(args);
    }
    else {
        objects = [self getObjectsForName:name idOnly:idOnly sortBy:sortBy asce:asce predicate:nil arguments:nil];
    }
    return objects;
}

- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly
                        sortBy:(NSString *)sortBy asce:(BOOL)asce
                         limit:(NSInteger)limit predicate:(NSString *)predicate, ...;
{
    NSArray *objects = nil;
    if (predicate) {
        va_list args;
        va_start(args, predicate);
        objects = [self getObjectsForName:name idOnly:idOnly sortBy:sortBy asce:asce limit:limit predicate:predicate arguments:args];
        va_end(args);
    }
    else {
        objects = [self getObjectsForName:name idOnly:idOnly sortBy:sortBy asce:asce limit:limit predicate:nil arguments:nil];
    }
    return objects;
}

- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly
                        sortBy:(NSString *)sortBy asce:(BOOL)asce
                         limit:(NSInteger)limit
                     predicate:(NSString *)predicate arguments:(va_list)arguments
{
    NSFetchRequest *fetchRequest = [self fetchRequestForName:name idOnly:idOnly predicate:predicate arguments:arguments];
    [fetchRequest setFetchLimit:limit];
    if (sortBy) {
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:sortBy ascending:asce];
        fetchRequest.sortDescriptors = @[ sortDesc ];
    }
    
    NSError *error;
    NSArray *objects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    return objects;
}

- (NSArray *)getObjectsForName:(NSString *)name idOnly:(BOOL)idOnly
                        sortBy:(NSString *)sortBy asce:(BOOL)asce
                     predicate:(NSString *)predicate arguments:(va_list)arguments
{
    NSFetchRequest *fetchRequest = [self fetchRequestForName:name idOnly:idOnly predicate:predicate arguments:arguments];
    
    if (sortBy) {
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:sortBy ascending:asce];
        fetchRequest.sortDescriptors = @[ sortDesc ];
    }
    
    NSError *error;
    NSArray *objects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    return objects;
}

- (void)removeObjectsForName:(NSString *)name
{
    [self removeObjectsForName:name predicate:nil];
}

- (void)removeObjectsForName:(NSString *)name predicate:(NSString *)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    NSArray *objects = [self getObjectsForName:name idOnly:YES sortBy:nil asce:NO predicate:predicate arguments:args];
    va_end(args);
    for (NSManagedObject *object in objects) {
        [self.context deleteObject:object];
    }
}

- (int)countForName:(NSString *)name
{
    return [self countForName:name predicate:nil];
}

- (int)countForName:(NSString *)name predicate:(NSString *)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    NSFetchRequest *fetchRequest = [self fetchRequestForName:name idOnly:YES predicate:predicate arguments:args];
    va_end(args);
    
    NSError *error;
    int count = (int)[self.context countForFetchRequest:fetchRequest error:&error];
    if (error) {
        return 0;
    }
    return count;
}

- (id)insertObjectForName:(NSString *)name
{
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.context];
}

- (NSEntityDescription *)entityDescriptionForName:(NSString *)name
{
    return [NSEntityDescription entityForName:name inManagedObjectContext:self.context];
}

- (NSFetchRequest *)fetchRequestForName:(NSString *)name idOnly:(BOOL)idOnly predicate:(NSString *)predicate arguments:(va_list)arguments
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.context];
    fetchRequest.includesPropertyValues = !idOnly;
    if (predicate) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:predicate arguments:arguments];
    }
    return fetchRequest;
}

@end
