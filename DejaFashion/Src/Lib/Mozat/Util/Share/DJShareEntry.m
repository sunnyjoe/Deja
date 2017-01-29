//
//  DJShareEntry.m
//  DejaFashion
//
//  Created by Kevin Lin on 10/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJShareEntry.h"

@implementation ShareParameter
@end

@implementation DJShareEntry

- (UIImage *)icon
{
    return nil;
}

- (void)share
{
    [self share:[[[UIApplication sharedApplication] delegate] window]];
    
}
- (void)share:(UIWindow *)window
{
    
}

- (NSString *)name
{
    return @"";
}

- (NSString *)labelName
{
    return @"";
}

@end
