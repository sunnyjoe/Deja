//
//  DJCopyURLShareEntry.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 19/5/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJCopyURLShareEntry.h"

@implementation DJCopyURLShareEntry

- (UIImage *)icon
{
    return [UIImage imageNamed:@"CopyIcon"];
}

- (void)share:(UIWindow *)window
{
    NSString *copyText = self.parameter.link;
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    [gpBoard setString:copyText];
    
    [MBProgressHUD showHUDAddedTo:self.showInViewController.view text:MOLocalizedString(@"Copied", @"") animated:YES];
}

- (NSString *)name
{
    return @"copy_url";
}

-(NSString *)labelName{
    return @"Copy URL";
}

@end
