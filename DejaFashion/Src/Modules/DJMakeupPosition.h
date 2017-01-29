//
//  DJMakeupPosition.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 1/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

/** It stores Makeup position relative to eye. For different eyes, makeup position needs adjustment.
 * It is logged in canthuspin.txt. We cache it in NSMutableDictionary * _makeupPosition;
 */

#import <Foundation/Foundation.h>

@interface DJMakeupPosition : NSObject

+ (NSMutableDictionary *)makeupPosistion;
+ (NSMutableDictionary *)getShadowupPosition;
@end
