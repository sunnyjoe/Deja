//
//  MBProgressHUD+ShowTextHUD.h
//  DejaFashion
//
//  Created by Kevin Lin on 12/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (ShowTextHUD)

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view text:(NSString *)text animated:(BOOL)animated;
+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view text:(NSString *)text duration:(int)duration;
+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view text:(NSString *)text duration:(int)duration oY:(float)oY;
@end
