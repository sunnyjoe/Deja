//
//  DJGetAddressBook.h
//  DejaFashion
//
//  Created by jiao qing on 21/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJGetAddressBook : NSObject
@property (nonatomic, strong) NSMutableArray *contacts;

-(void)getContacts:(void (^)())completion;
@end
