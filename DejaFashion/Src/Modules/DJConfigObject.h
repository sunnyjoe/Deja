//
//  DJConfigObject.h
//  DejaFashion
//
//  Created by Sun lin on 8/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DJConfigObject : NSManagedObject

@property (nonatomic, retain) NSString *configID;
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSData *originalData;

@end
