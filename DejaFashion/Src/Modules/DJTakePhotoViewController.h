//
//  DJTakePhotoViewController.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 19/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJBasicViewController.h"
 
@class DJTakePhotoViewController;

@protocol DJTakePhotoViewControllerDelegate <NSObject>
- (void)takePhotoViewController:(DJTakePhotoViewController *)takePhototVC didUseImage:(UIImage *)image;
@end

@interface DJTakePhotoViewController: DJBasicViewController
@property (nonatomic, weak) id<DJTakePhotoViewControllerDelegate> delegate;
@property (assign, nonatomic) CGRect maskRect;
@end
