//
//  DJUploadPhotoViewController.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 18/6/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJBasicViewController.h"

@class DJUploadPhotoViewController;

@protocol DJUploadPhotoViewControllerDelegate <NSObject>

- (void)uploadPhotoViewControllerDidClickTakePhoto:(DJUploadPhotoViewController *)uploadPhotoViewController;
- (void)uploadPhotoViewController:(DJUploadPhotoViewController *)uploadPhotoViewController uploadPhoto:(UIImage *)image;
- (void)uploadPhotoViewControllerDidClickCancel:(DJUploadPhotoViewController *)uploadPhotoViewController;

@end


@interface DJUploadPhotoViewController : DJBasicViewController
@property (nonatomic, weak) id<DJUploadPhotoViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *uploadImage;
@property (assign, nonatomic) CGRect maskRect;
@end

