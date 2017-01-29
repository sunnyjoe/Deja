//
//  UIApplication+Mozat.h
//  DejaFashion
//
//  Created by Sun lin on 15/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Mozat)

-(BOOL)openUrlIfCan:(NSString *)urlString;

-(BOOL)openUrlFormatIfCan:(NSString *)format, ...;
@end
