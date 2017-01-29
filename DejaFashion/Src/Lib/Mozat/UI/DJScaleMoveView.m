//
//  DJScaleMoveView.m
//  DejaFashion
//
//  Created by jiao qing on 4/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "DJScaleMoveView.h"

@interface DJScaleMoveView ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIImageView *innerImageView;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (assign, nonatomic) float lastScale;
@property (assign, nonatomic) float beginX;
@property (assign, nonatomic) float beginY;
@end


@implementation DJScaleMoveView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.maskRect = CGRectMake(100, 150, self.frame.size.width - 200, self.frame.size.height - 300);
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.clipsToBounds = YES;
    
    self.innerImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.innerImageView.userInteractionEnabled = YES;
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePhoto)];
    [self.pinchRecognizer setDelegate:self];
    [self.innerImageView addGestureRecognizer:self.pinchRecognizer];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePhoto)];
    [self.panRecognizer setMinimumNumberOfTouches:1];
    [self.panRecognizer setMaximumNumberOfTouches:1];
    [self.panRecognizer setDelegate:self];
    [self.innerImageView addGestureRecognizer:self.panRecognizer];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect tmp = self.innerImageView.frame;
    if (tmp.size.width == 0) {
        [self resetImage:self.theImage];
    }
}

-(UIImageView *)innerImageView{
    if (_innerImageView == nil) {
        _innerImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_innerImageView];
    }
    return _innerImageView;
}


-(void)resetImage:(UIImage *)theImage{
    self.innerImageView.image = theImage;
    self.theImage = theImage;
    
    if (theImage.size.width > 0 && theImage.size.height > 0) {
        float imageRatio = theImage.size.height / theImage.size.width;
        float viewRatio = self.frame.size.height / self.frame.size.width;
        if(imageRatio > viewRatio){
            float newImageHeight = self.frame.size.height;
            float newImageWidth = newImageHeight / imageRatio;
            self.innerImageView.frame = CGRectMake(self.frame.size.width / 2 - newImageWidth / 2, self.frame.size.height / 2 - newImageHeight / 2, newImageWidth, newImageHeight);
        }else{
            float newImageWidth = self.frame.size.width;
            float newImageHeight = newImageWidth * imageRatio;
            self.innerImageView.frame = CGRectMake(self.frame.size.width / 2 - newImageWidth / 2, self.frame.size.height / 2 - newImageHeight / 2, newImageWidth,newImageHeight);
        }
    }else{
        self.innerImageView.frame = self.bounds;
    }
}

-(CGRect)getImageViewFrame{
    return self.innerImageView.frame;
}

-(UIImage *)clipImageWithImage:(UIImage *)image{
    CGRect innerRect = self.innerImageView.frame;
    UIImage *sourceImage = self.innerImageView.image;
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 2);
    [image drawInRect:self.bounds];
    [sourceImage drawInRect:innerRect blendMode:kCGBlendModeSourceOut alpha:1];
    [image drawInRect:self.bounds blendMode:kCGBlendModeDestinationOut alpha:1];
    UIImage *clipedImage = UIGraphicsGetImageFromCurrentImageContext();// The final image.
    UIGraphicsEndImageContext();
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextScaleCTM(context, 1, -1);
    //    CGContextTranslateCTM(context, 0, - self.frame.size.height);
    //    CGContextSetBlendMode(context, kCGBlendModeSourceOut);
    //    CGContextDrawImage(context, self.bounds, image.CGImage);
    //    CGContextDrawImage(context, innerRect, sourceImage.CGImage);
    //    UIImage *clipedImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    return clipedImage;
}

-(UIImage *)clipImageByMaskRect{
    float xLeftBorder =  MAX(self.innerImageView.frame.origin.x, self.maskRect.origin.x);
    float xRightBorder =  MIN(CGRectGetMaxX(self.innerImageView.frame), CGRectGetMaxX(self.maskRect));
    if (xLeftBorder >= xRightBorder) {
        return nil;
    }
    
    float yUpperBorder =  MAX(self.innerImageView.frame.origin.y, self.maskRect.origin.y);
    float yLowerBorder =  MIN(CGRectGetMaxY(self.innerImageView.frame), CGRectGetMaxY(self.maskRect));
    
    if (yUpperBorder >= yLowerBorder) {
        return nil;
    }
    
    float scale = self.innerImageView.image.size.width / MAX(self.innerImageView.frame.size.width,1);
    
    CGSize clipSize = CGSizeMake((xRightBorder - xLeftBorder) * scale, (yLowerBorder - yUpperBorder) * scale);
    float oX = 0;
    float oY = 0;
    if (fabs(xLeftBorder - self.maskRect.origin.x) < 1) {
        oX = (self.maskRect.origin.x - self.innerImageView.frame.origin.x) * scale;
    }
    if (fabs(yUpperBorder - self.maskRect.origin.y) < 1) {
        oY = (self.maskRect.origin.y - self.innerImageView.frame.origin.y) * scale;
    }
    
    CGRect clipRect = CGRectMake(-oX, -oY, self.innerImageView.frame.size.width * scale, self.innerImageView.frame.size.height * scale);
    
    UIGraphicsBeginImageContextWithOptions(clipSize, 1, 1);
    [self.innerImageView.image drawInRect:clipRect];
    UIImage *clipedImage = UIGraphicsGetImageFromCurrentImageContext();// The final image.
    UIGraphicsEndImageContext();
    
    return clipedImage;
}

-(void)scalePhoto{
    if(self.pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    CGFloat scale = 1.0 - (_lastScale - self.pinchRecognizer.scale);
    CGAffineTransform currentTransform = self.innerImageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [self.innerImageView setTransform:newTransform];
    
    CGFloat maskheight = self.maskRect.size.height;
    
    _lastScale = self.pinchRecognizer.scale;
    if (self.pinchRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect tmpFrame = self.innerImageView.frame;
        if (tmpFrame.size.height < maskheight || tmpFrame.size.width < self.frame.size.width - self.maskRect.origin.x * 2) {
            float widthScale = maskheight / tmpFrame.size.height;
            float heightScale = (self.frame.size.width - self.maskRect.origin.x * 2) / tmpFrame.size.width;
            
            scale = MAX(widthScale, heightScale);
            CGRect scaledFrame = CGRectMake(tmpFrame.origin.x - (scale - 1) * tmpFrame.size.width / 2, tmpFrame.origin.y - (scale - 1) * tmpFrame.size.height / 2, tmpFrame.size.width * scale, tmpFrame.size.height * scale);
            CGPoint adjustPoint = [self calculateAdjustPhotoViewFrame:scaledFrame];
            
            __weak DJScaleMoveView *weakSelf = self;
            [UIView animateWithDuration:0.2 delay:0
                                options:UIViewAnimationOptionTransitionNone
                             animations:^{
                                 weakSelf.innerImageView.frame = CGRectMake(adjustPoint.x, adjustPoint.y, scaledFrame.size.width, scaledFrame.size.height);
                             }
                             completion:nil
             ];
            return;
        }
    }
}

-(void)movePhoto{
    CGPoint translatedPoint = [self.panRecognizer translationInView:self];
    if(self.panRecognizer.state == UIGestureRecognizerStateBegan) {
        _beginX = [self.innerImageView center].x;
        _beginY = [self.innerImageView center].y;
    }
    
    translatedPoint = CGPointMake(_beginX + translatedPoint.x, _beginY + translatedPoint.y);
    [self.innerImageView setCenter:translatedPoint];
    
    if (self.panRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect tmpFrame = self.innerImageView.frame;
        CGPoint adjustPoint = [self calculateAdjustPhotoViewFrame:tmpFrame];
        __weak DJScaleMoveView *weakSelf = self;
        [UIView animateWithDuration:0.35 delay:0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             weakSelf.innerImageView.frame = CGRectMake(adjustPoint.x, adjustPoint.y, tmpFrame.size.width, tmpFrame.size.height);
                         }
                         completion:nil
         ];
    }
}

-(CGPoint )calculateAdjustPhotoViewFrame:(CGRect)tmpFrame{
    float Y = tmpFrame.origin.y;
    float X = tmpFrame.origin.x;
    
    CGFloat xDistance = self.maskRect.origin.x;
    CGFloat yDistance = self.maskRect.origin.y;
    
    if (tmpFrame.origin.y > CGRectGetMaxY(self.maskRect)|| CGRectGetMaxY(tmpFrame) < yDistance|| tmpFrame.origin.x > CGRectGetMaxX(self.maskRect) || CGRectGetMaxX(tmpFrame) < xDistance) {
        if (tmpFrame.origin.y > CGRectGetMaxY(self.maskRect)){
            Y -= tmpFrame.origin.y - CGRectGetMaxY(self.maskRect);
        }else if (CGRectGetMaxY(tmpFrame) < yDistance){
            Y += yDistance - CGRectGetMaxY(tmpFrame);
        }
        
        if (CGRectGetMaxX(tmpFrame) < xDistance){
            X += xDistance - CGRectGetMaxX(tmpFrame);
        }else if (tmpFrame.origin.x > CGRectGetMaxX(self.maskRect)){
            X -= tmpFrame.origin.x - CGRectGetMaxX(self.maskRect);
        }
    }
    return CGPointMake(X, Y);
}

@end