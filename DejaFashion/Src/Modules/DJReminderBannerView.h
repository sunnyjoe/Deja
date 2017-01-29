//
//  DJReminderBannerView.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 4/8/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJReminderBannerView : UIView
@property (strong, nonatomic) NSString *labelStr;

-(void)bannerAnimationDownUp;
-(void)bannerAnimationInOut;
@end
