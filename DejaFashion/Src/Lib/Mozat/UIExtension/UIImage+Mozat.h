//
//  UIImage+MOAdditions.h
//  DejaFashion
//
//  Created by Sun lin on 27/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Mozat)

- (UIColor *)colorAtPixel:(CGPoint)point;

+ (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg topleft:(CGPoint)tlPos;
+ (UIImage *)rotateImage:(UIImage *)inputImage rotate:(float)degree;
+ (UIImage *)resizeImageRetina:(UIImage *)inputImage size:(CGSize)newSize;
//- (UIColor*)getPixelColorAtLocation:(CGPoint)point;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color andSize: (CGSize)size;

+(UIImage *)imageFileNamed:(NSString *)filename;
+(UIImage *)correctCameraImage:(UIImage *)inputImage;

/**
 * Return the name of the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The name of the splash image.
 **/
+ (NSString *)si_splashImageNameForOrientation:(UIDeviceOrientation)orientation;

/**
 * Returns the splash image for a given orientation.
 * @param orientation The interface orientation.
 * @return The splash image.
 **/
+ (UIImage*)si_splashImageForOrientation:(UIDeviceOrientation)orientation;

@end
