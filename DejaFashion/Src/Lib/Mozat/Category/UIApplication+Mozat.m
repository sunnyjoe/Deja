//
//  UIApplication+Mozat.m
//  DejaFashion
//
//  Created by Sun lin on 15/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "UIApplication+Mozat.h"

@implementation UIApplication (Mozat)

-(BOOL)openUrlIfCan:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    else{
        return NO;
    }
}


-(BOOL)openUrlFormatIfCan:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *urlString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self openUrlIfCan:urlString];
}
@end
