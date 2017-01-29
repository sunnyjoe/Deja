//
//  DJNetworkFailedTip.h
//  DejaFashion
//
//  Created by DanyChen on 3/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJNetworkFailedTip : NSObject

+ (void)showSlideDown: (float)originY insideParentView: (UIView *)parentView;

+ (void)showToast: (UIView *)parentView;

@end
