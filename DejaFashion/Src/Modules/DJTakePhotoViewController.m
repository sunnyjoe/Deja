//
//  DJTakePhotoViewController.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 19/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJTakePhotoViewController.h"
#import "DJCameraPreview.h"
#import "UIImage+Mozat.h"
#import "DJSelectionModels.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DJAlertView.h"
#import "DJConfigDataContainer.h"
#import "DJUploadPhotoViewController.h"
#import "DJAblumOperation.h"

@interface DJTakePhotoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DJCameraPreviewDelegate, DJUploadPhotoViewControllerDelegate>
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) DJCameraPreview *cameraPreview;
@property (assign, nonatomic) BOOL usePhotoCalled;
@property (assign, nonatomic) NSInteger from;
@property (assign, nonatomic) BOOL flashOn;
@property (strong, nonatomic) UIButton *flash;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) AVCaptureSession * avSession;
@property (strong, nonatomic) UIButton *cameraReflect;
@property (strong, nonatomic) UIView *cameraFunctionBar;
@property (strong, nonatomic) ALAssetsLibrary *assetLibrary;
@property (strong, nonatomic) UIButton *takePhoto;
@property (strong, nonatomic) UIButton *ablum;
@end

@implementation DJTakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageWriteToSavedPhotosAlbum([UIImage new], NULL, NULL, NULL);
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kFunctionPanelHeight - 64)];
    [self.view addSubview:self.contentView];
    DebugLayer(self.contentView, 1.0, [UIColor redColor].CGColor);
    
    
    DJButton *cancelBtn = [DJButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:MOLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [cancelBtn setButtonWithStateColor];
    [cancelBtn addTarget:self action:@selector(cancelBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    // The View display the photo recording by the camera.
    self.cameraPreview = [[DJCameraPreview alloc] initWithFrame:self.contentView.bounds withPreviewOpenHandler:nil];
    self.cameraPreview.delegate = self;
    self.cameraPreview.clipsToBounds = YES;
    self.cameraPreview.contentMode = UIViewContentModeScaleAspectFill;
    self.cameraPreview.layer.cornerRadius = 0;
    [self.contentView addSubview:self.cameraPreview];
    
    CGRect cameraBarRect = CGRectMake(0, self.contentView.frame.size.height - 45 * kIphoneSizeScale, kScreenWidth, 45 * kIphoneSizeScale);
    
    self.cameraReflect = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 10 - cameraBarRect.size.height, 0, cameraBarRect.size.height, cameraBarRect.size.height)];
    [self.cameraReflect addTarget:self action:@selector(cameraFrontOrBackSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraReflect setImage:[UIImage imageNamed:@"CameraFlipNormal"] forState:UIControlStateNormal];
    [self.cameraReflect setImage:[UIImage imageNamed:@"CameraFlipPressed"] forState:UIControlStateHighlighted];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasFlash]) {
        self.flash = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, cameraBarRect.size.height, cameraBarRect.size.height)];
        [self.flash addTarget:self action:@selector(turnFlashLight) forControlEvents:UIControlEventTouchUpInside];
        [self.flash setImage:[UIImage imageNamed:@"CameraFlashOnNormal"] forState:UIControlStateNormal];
        [self.flash setImage:[UIImage imageNamed:@"CameraFlashOnPressed"] forState:UIControlStateHighlighted];
        self.flashOn = YES;
    }
    self.cameraFunctionBar = [[UIView alloc] initWithFrame:cameraBarRect];
    [self.contentView addSubview:self.cameraFunctionBar];
    [self.cameraFunctionBar setBackgroundColor:[UIColor colorFromHexString:@"#000000" alpha:0.6]];
    [self.cameraFunctionBar addSubview:self.cameraReflect];
    [self.cameraFunctionBar addSubview:self.flash];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height, self.view.frame.size.width, kFunctionPanelHeight)];
    bottomView.backgroundColor = [UIColor colorFromHexString:@"262729"];
    [self.view addSubview:bottomView];
    
    NSInteger width = 55 * kIphoneSizeScale;
    if (kScreenWidth <= 320) {
        width = 55;
    }
    self.ablum = [[UIButton alloc] initWithFrame:CGRectMake(10, (kFunctionPanelHeight - 55 * kIphoneSizeScale) / 2,
                                                            width, 55 * kIphoneSizeScale)];
    [bottomView addSubview:self.ablum];
    self.ablum.contentMode = UIViewContentModeScaleAspectFill;
    [self.ablum addTarget:self action:@selector(choosePicture) forControlEvents:UIControlEventTouchUpInside];
    [self getAlbumPoster];
    
    self.takePhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70 * kIphoneSizeScale, 70 * kIphoneSizeScale)];
    self.takePhoto.center = CGPointMake(kScreenWidth / 2, kFunctionPanelHeight / 2);
    [self.takePhoto setImage:[UIImage imageNamed:@"CameraButtonNormal"] forState:UIControlStateNormal];
    [self.takePhoto setImage:[UIImage imageNamed:@"CameraButtonPressed"] forState:UIControlStateHighlighted];
    [bottomView addSubview:self.takePhoto];
    [self.takePhoto addTarget:self action:@selector(capturePhoto) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.cameraPreview startSession];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.cameraPreview stopSession];
}

-(void)cancelBtnDidClick{
    [self.cameraPreview stopSession];
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:true completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void)getAlbumPoster {
    void (^completion)(UIImage *) = ^(UIImage *thePoster){
        if (thePoster) {
            [self.ablum setImage:thePoster forState:UIControlStateNormal];
        }
    };
    
    [DJAblumOperation getAlbumPoster:completion];
}

-(void)checkCameraAccess{
    if ([[DJConfigDataContainer instance] openAppCounterIncreaseOne:NO] <= 2) {
        [[DJConfigDataContainer instance] showAccessAlertViewForKey:kDJCameraPermissionIdentifier];
    }else{
        [[DJConfigDataContainer instance] showEnableAccessAlertViewForKey:kDJCameraPermissionIdentifier withViewDelegate:nil];
    }
}

- (void)capturePhoto
{
    if (![self.cameraPreview isRunning]) {
        [[[DJAlertView alloc] initWithTitle:@""
                                    message:MOLocalizedString(@"Opps, something is wrong with your camera. Try restarting Deja or your phone.", @"")
                                   delegate:nil
                          cancelButtonTitle:MOLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
        return;
    }
    if(![[DJConfigDataContainer instance] checkPermissionForKey:kDJCameraPermissionIdentifier]){
        [self checkCameraAccess];
        return;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureSession * session = self.cameraPreview.captureManager.session;
    
    if (!self.flash.hidden && self.flash && self.flashOn) {
        [session beginConfiguration];
        [device lockForConfiguration:nil];
        if([device hasFlash]) {
            [device setFlashMode:AVCaptureFlashModeOn];
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        [device unlockForConfiguration];
        [session commitConfiguration];
    }
    __weak DJTakePhotoViewController *weakSelf = self;
    [self.cameraPreview captureStillImage:nil completion:^{
        if (!weakSelf.flash.hidden && weakSelf.flash && weakSelf.flashOn) {
            [session beginConfiguration];
            [device lockForConfiguration:nil];
            if([device hasFlash]) {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
            [session commitConfiguration];
        }
    }];
}

-(void)showPhotoForDeJaFace:(UIImage *)image{
    self.usePhotoCalled = YES;
    
    DJUploadPhotoViewController *uploadVC = [DJUploadPhotoViewController new];
    uploadVC.uploadImage = image;
    uploadVC.delegate = self;
    uploadVC.title = self.title;
    if (self.maskRect.size.width != 0) {
        uploadVC.maskRect = self.maskRect;
    }
    [self.navigationController pushViewController:uploadVC animated:NO];
}

#pragma mark DJUploadPhotoViewControllerDelegate
- (void)uploadPhotoViewControllerDidClickTakePhoto:(DJUploadPhotoViewController *)uploadPhotoViewController{
    [uploadPhotoViewController.navigationController popViewControllerAnimated:true];
}

- (void)uploadPhotoViewController:(DJUploadPhotoViewController *)uploadPhotoViewController uploadPhoto:(UIImage *)image{
    [self dismissViewControllerAnimated:true completion:^{
        if ([self.delegate respondsToSelector:@selector(takePhotoViewController:didUseImage:)]) {
            [self.delegate takePhotoViewController:self didUseImage:image];
        }
    }];
}

- (void)uploadPhotoViewControllerDidClickCancel:(DJUploadPhotoViewController *)uploadPhotoViewController{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)choosePicture {
    if(![[DJConfigDataContainer instance] checkPermissionForKey:kDJAlbumPermissionIdentifier]){
        [[DJConfigDataContainer instance] showEnableAccessAlertViewForKey:kDJAlbumPermissionIdentifier withViewDelegate:nil];
        
    }
    
    [DJAblumOperation choosePicture:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (!img) {
        return;
    }
    [self showPhotoForDeJaFace:img];
}

-(BOOL)isUseFrontCamera{
    AVCaptureDevice *device = [[[self.cameraPreview captureManager] videoInput] device];
    if ([device position] == AVCaptureDevicePositionFront) {
        return YES;
    }
    return NO;
}

- (void)cameraFrontOrBackSwitch {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if(devices == nil || devices.count <= 1)
    {
        return;
    }
    // Toggle between cameras when there is more than one
    [[self.cameraPreview captureManager] toggleCamera];
    
    self.flash.hidden = NO;
    if ([self isUseFrontCamera]) {
        self.flash.hidden = YES;
    }
    
    [[self.cameraPreview captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (void)turnFlashLight {
    self.flashOn = !self.flashOn;
    
    if (!self.flashOn) {
        [self.flash setImage:[UIImage imageNamed:@"CameraFlashOffNormal"] forState:UIControlStateNormal];
        [self.flash setImage:[UIImage imageNamed:@"CameraFlashOffPressed"] forState:UIControlStateHighlighted];
    }
    else {
        [self.flash setImage:[UIImage imageNamed:@"CameraFlashOnNormal"] forState:UIControlStateNormal];
        [self.flash setImage:[UIImage imageNamed:@"CameraFlashOnPressed"] forState:UIControlStateHighlighted];
    }
}


#pragma DJCameraPreviewDelegate
-(void)cameraPreviewdidFinishCapture{
    UIImageWriteToSavedPhotosAlbum(self.cameraPreview.image, NULL, NULL, NULL);
    [self showPhotoForDeJaFace:self.cameraPreview.image];
}

@end
