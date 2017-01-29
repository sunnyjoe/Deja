//
//  DJSaveImageShareEntry.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 19/5/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJSaveImageShareEntry.h"
#import "DJConfigDataContainer.h"

@implementation DJSaveImageShareEntry
- (UIImage *)icon
{
    return [UIImage imageNamed:@"SaveImageIconNormal"];
}

- (void)share:(UIWindow *)window
{
    UIImageWriteToSavedPhotosAlbum(self.parameter.thumb, NULL, NULL, NULL);
    
}
- (NSString *)name
{
    return @"save_img";
}

-(NSString *)labelName{
    return @"Save Image";
}


@end
