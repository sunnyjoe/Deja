//
//  NSURL+Mozat.m
//  DejaFashion
//
//  Created by Sun lin on 14/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "NSURL+Mozat.h"

@implementation NSURL (Mozat)


+ (NSURL *)urlWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *urlString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [NSURL URLWithString:urlString];
}

@end
