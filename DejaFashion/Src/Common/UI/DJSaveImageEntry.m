//
//  DJSaveImageEntry.m
//  DejaFashion
//
//  Created by Kevin Lin on 10/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJSaveImageEntry.h"

@implementation DJSaveImageEntry

- (UIImage *)icon
{
    return [UIImage imageNamed:@"SaveImage"];
}

- (void)share
{
    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
}

- (NSString *)name
{
    return @"save";
}

@end
