//
//  DJDefinedSize.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 21/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//


#ifndef DejaFashion_DJDefinedSize_h
#define DejaFashion_DJDefinedSize_h

#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define kNavigationBarHeight self.navigationController.navigationBar.frame.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


#define kIphoneSizeScale kScreenWidth / 375 // 414/375 relative to iphone 6
#define kIphoneHeightScale kScreenHeight / 667  // 667 point in iphone 6 vertical
#define kFunctionPanelHeight 85  * kIphoneSizeScale

#define kDJMainTabBarHeight 55

#endif
