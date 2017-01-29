//
//  DJFileManager.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 4/3/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJFileManager : NSObject
+ (BOOL)isFileExist:(NSString *)name;
+(NSString *)getStringFromTxtFile:(NSString *)fileName;
@end
