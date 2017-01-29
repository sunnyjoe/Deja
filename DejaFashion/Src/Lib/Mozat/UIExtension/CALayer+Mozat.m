//
//  CALayer+MOAdditions.m
//  DejaFashion
//
//  Created by Sun lin on 27/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "CALayer+Mozat.h"

@implementation CALayer (MOAdditions)

-(void)removeAllSubLayers{
    NSArray *layerToRemove = [self.sublayers copy];
    for (CALayer *l in layerToRemove) {
        [l removeFromSuperlayer];
    }
}

-(UIImage *)getImageFromLayer
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
