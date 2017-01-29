//
//  DJScaleMoveView.h
//  DejaFashion
//
//  Created by jiao qing on 4/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJScaleMoveView : UIView
@property (assign, nonatomic) CGRect maskRect;
@property (assign, nonatomic) UIImage *theImage;

-(void)resetImage:(UIImage *)theImage;
-(UIImage *)clipImageByMaskRect;
-(UIImage *)clipImageWithImage:(UIImage *)image;
-(CGRect)getImageViewFrame;
@end
