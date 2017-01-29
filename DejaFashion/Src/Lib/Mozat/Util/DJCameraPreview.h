//
//  DJCameraPreview.h
//  DejaFashion
//
//  Created by Sunny XiaoQing on 3/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCamCaptureManager.h"

@class DJCameraPreview;
@protocol DJCameraPreviewDelegate <NSObject>

-(void)cameraPreviewdidFinishCapture;

@end

@interface DJCameraPreview : UIImageView <AVCamCaptureManagerDelegate>
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, assign) id <DJCameraPreviewDelegate> delegate;

- (IBAction)toggleCamera:(id)sender;
- (IBAction)captureStillImage:(id)sender completion:(void (^)())completionHandler;
- (void)startSession;
- (void)stopSession;
- (id)initWithFrame:(CGRect)frame withPreviewOpenHandler:(void(^)(void))handler;

@end
