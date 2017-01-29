//
//  DJCameraPreview.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 3/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJCameraPreview.h"
#import "DJAlertView.h"

@implementation DJCameraPreview

@synthesize captureManager;
@synthesize captureVideoPreviewLayer;
@synthesize isRunning;
- (void)dealloc {
    self.captureManager = nil;
    self.captureVideoPreviewLayer = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame withPreviewOpenHandler:(void(^)(void))handler
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        if (self.captureManager == nil)
        {
            self.captureManager = [AVCamCaptureManager sharedInstance];
            self.captureManager.delegate = self;
            
            if ([self.captureManager setupSession])
            {
                // Create video preview layer and add it to the UI
                // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{ // calling this after session starts endures no camera black out on iOS7
                        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
                        UIView *view = self;
                        CALayer *viewLayer = [view layer];
                        [viewLayer setMasksToBounds:YES];
                        CGRect bounds = [view bounds];
                        [newCaptureVideoPreviewLayer setFrame:bounds];
                        [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                        [viewLayer insertSublayer:newCaptureVideoPreviewLayer atIndex:0];
                        [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
                        [newCaptureVideoPreviewLayer release];
                        if (handler)
                        {
                            handler();
                        }
                    });
                });
                [[self.captureManager session] startRunning];
                self.isRunning = YES;
            }
        }
    }
    return self;
}

- (void)startSession
{
    [self.layer insertSublayer:self.captureVideoPreviewLayer atIndex:0];
    [self setImage:nil];
    [[[self captureManager] session] startRunning];
    self.isRunning = YES;
}

- (void)stopSession {
    [self.captureVideoPreviewLayer removeFromSuperlayer];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[[self captureManager] session] stopRunning];
        self.isRunning = NO;
    });
}

- (IBAction)toggleCamera:(id)sender
{
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
    
}

- (IBAction)captureStillImage:(id)sender completion:(void (^)())completionHandler
{
    // Capture a still image
    if (![self captureManager].session.isRunning) {
        return;
    }
    if([[self captureManager] captureStillImage]) {
        // Flash the screen white and fade it out to give UI feedback that a still image was taken
        UIView *flashView = [[UIView alloc] initWithFrame:self.bounds];
        [flashView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:flashView];
        
        [UIView animateWithDuration:.8f
                         animations:^{
                             [flashView setAlpha:0.f];
                         }
                         completion:^(BOOL finished){
                             [self.captureVideoPreviewLayer removeFromSuperlayer];
                             [flashView removeFromSuperview];
                             [flashView release];
                             
                             if (completionHandler) {
                                 completionHandler();
                             }
                         }
         ];
    }
}

#pragma mark - AVCAMCaptureManager delegates

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        DJAlertView *alertView = [[DJAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:MOLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}


- (void)captureManagerStillImageCaptured:(UIImage *)image
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [self stopSession];
        
        // imageByScaleWithBoundRetina.
        CGSize bound = [UIScreen mainScreen].bounds.size;
        CGSize imageSize = image.size;
        float scale = MIN(bound.width / imageSize.width, bound.height / imageSize.height);
        imageSize.width *= scale;
        imageSize.height *= scale;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (captureManager.videoInput.device.position == AVCaptureDevicePositionFront) {
            // imageflipHorizonatally.
            UIGraphicsBeginImageContextWithOptions(img.size, NO, 0);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(ctx, -1.0, 1.0);
            CGContextTranslateCTM(ctx, -img.size.width, 0);
            [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        [self setImage:img];
        
        if ([self.delegate respondsToSelector:@selector(cameraPreviewdidFinishCapture)]) {
            [self.delegate cameraPreviewdidFinishCapture];
        }
    });
    
}


@end
