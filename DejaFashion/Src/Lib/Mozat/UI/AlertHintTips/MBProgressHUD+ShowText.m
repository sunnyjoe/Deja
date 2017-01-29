//
//  MBProgressHUD+ShowText.m
//  DejaFashion
//
//  Created by Kevin Lin on 12/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "MBProgressHUD+ShowText.h"

@implementation MBProgressHUD (ShowTextHUD)

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view text:(NSString *)text animated:(BOOL)animated
{
    MBProgressHUD *hud = [[self alloc] initWithView:view];
    hud.cornerRadius = 0;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = text;
    // hud.yOffset = 100;
    [view addSubview:hud];
    [hud show:animated];
    [hud hide:animated afterDelay:1];
    return hud;
}

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view text:(NSString *)text duration:(int)duration
{
    MBProgressHUD *hud = [[self alloc] initWithView:view];
    hud.userInteractionEnabled = false;
    hud.cornerRadius = 0;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = text;
    // hud.yOffset = 100;
    [view addSubview:hud];
    [hud show:true];
    hud.removeFromSuperViewOnHide = true;
    [hud hide:true afterDelay:duration];
    return hud;
}

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view text:(NSString *)text duration:(int)duration oY:(float)oY
{
    MBProgressHUD *hud = [[self alloc] initWithView:view];
    hud.userInteractionEnabled = false;
    hud.cornerRadius = 0;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = text;
    //  hud.yOffset = oY;
    [view addSubview:hud];
    [hud show:true];
    hud.removeFromSuperViewOnHide = true;
    [hud hide:true afterDelay:duration];
    return hud;
}

@end
