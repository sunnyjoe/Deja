//
//  DJAblumOperation.h
//  DejaFashion
//
//  Created by jiao qing on 8/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DJAblumOperation : NSObject
@property (nonatomic, weak) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;

+ (void)choosePicture:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> *)delegate;
+ (void)getAlbumPoster:(void (^)(UIImage *))completion;
+ (void)saveImageToAlbum:(UIImage *)image;
@end
