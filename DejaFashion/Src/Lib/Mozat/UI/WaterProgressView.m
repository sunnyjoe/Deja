//
//  CCProgressView.m
//  ProgressViewDemo
//
//  Created by mr.cao on 14-5-27.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import "WaterProgressView.h"
#import <CoreMotion/CoreMotion.h>
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface CCProgressView : UIView
@property (nonatomic, strong) CAGradientLayer* gradientLayer;
@property (nonatomic, strong)  NSTimer *theTimer;

@property (nonatomic, strong) CMMotionManager* motionManager;
@property (nonatomic, strong) CADisplayLink* motionDisplayLink;
@property (nonatomic, assign) float motionLastYaw;
@property (nonatomic, assign) float waveOffSet;

@property (nonatomic, assign) CGAffineTransform currentTransform;
@property (nonatomic, assign) CGAffineTransform newTransform;
@property (nonatomic, assign) float currentLinePointY;
@property (nonatomic, strong) UIColor *currentWaterColor;
@property (nonatomic, strong) NSTimer *gravityTimer;

@end

@implementation CCProgressView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer*)self.layer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2) radius:self.frame.size.height * 0.5 startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(360) clockwise:YES];
        
        CAShapeLayer* maskLayer = [CAShapeLayer layer];
        maskLayer.path = circlePath.CGPath;
        self.gradientLayer.mask = maskLayer;
    
        self.layer.borderColor = [UIColor colorFromHexString:@"f81f34"].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = frame.size.width / 2;
        
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval = 0.1;// 0.02; // 50 Hz
        if ([self.motionManager isDeviceMotionAvailable]) {
            [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
        }
        
        _currentTransform = self.transform;
        self.motionLastYaw = 0;
        __weak CCProgressView * weakSelf = self;
        self.gravityTimer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:weakSelf selector:@selector(motionRefresh:) userInfo:nil repeats:YES];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_currentWaterColor CGColor]);
    
    float y=_currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    for(float x=0; x <= self.frame.size.width; x++){
        float perc = x * 2 * M_PI / self.frame.size.width;
        y = _currentLinePointY - sin(perc + _waveOffSet);
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, self.frame.size.width, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    CGFloat rescaledProgress = MIN(MAX(progress, 0.f), 1.f);
    NSArray* newLocations =@[[NSNumber numberWithFloat:rescaledProgress], [NSNumber numberWithFloat:rescaledProgress]];
    
    self.gradientLayer.locations = newLocations;
    _waveOffSet = 0;
    
    _currentLinePointY = self.frame.size.height * (1 - progress);
    _currentWaterColor = [UIColor colorFromHexString:@"f81f34"];
    
    if(_theTimer)
    {
        [_theTimer invalidate];
        _theTimer=nil;
    }
    _theTimer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
}

-(void)animateWave
{
    _waveOffSet += 12 * M_PI/ 180;
    
    [self setNeedsDisplay];
}

- (void)motionRefresh:(id)sender
{
    CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
    yaw *= -1;      // reverse the angle so that it reflect a *liquid-like* behavior
    
    if (self.motionLastYaw == 0) {
        self.motionLastYaw = yaw;
    }
    
    // kalman filtering
    static float q = 0.1;   // process noise
    static float s = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
    
    float x = self.motionLastYaw;
    p = p + q;
    k = p / (p + s);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
    
    _newTransform = CGAffineTransformRotate(_currentTransform,-x);
    self.transform = _newTransform;
    
    self.motionLastYaw = x;
}

- (void)dealloc
{
    [_motionDisplayLink invalidate];
    _motionDisplayLink = nil;
    
    [_gravityTimer invalidate];
    _gravityTimer=nil;
    _motionManager = nil;   // release the motion manager memory
    
    if ([_motionManager isDeviceMotionActive])
        [_motionManager stopDeviceMotionUpdates];
}
@end


@interface WaterProgressView ()
@property (nonatomic, strong) CCProgressView *mainView;
@end

@implementation WaterProgressView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.mainView = [[CCProgressView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.mainView];
        
        UIImageView *dejaBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        dejaBG.image = [UIImage imageNamed:@"ScoreDejaIcon"];
        dejaBG.userInteractionEnabled = YES;
        [dejaBG addTapGestureTarget:self action:@selector(dejaIconDidTapped)];
        [self addSubview:dejaBG];
    }
    return self;
}

- (void)dejaIconDidTapped{
    [self.delegate waterProgressViewDidClick:self];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated{
    [self.mainView setProgress:progress animated:animated];
    
}
@end