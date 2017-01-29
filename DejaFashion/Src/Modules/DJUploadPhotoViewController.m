//
//  DJUploadPhotoViewController.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 18/6/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJUploadPhotoViewController.h"
#import "DejaFashion-swift.h"
#import "DJScaleMoveView.h"

#define kDJExitDejaCreationAlertViewTage 1

@interface DJUploadPhotoViewController ()

@property (strong, nonatomic) DJScaleMoveView *contentView;

@property (strong, nonatomic) UIImageView *photoRule;
@property (strong, nonatomic) UIBarButtonItem *cancel;
@end

@implementation DJUploadPhotoViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.maskRect = CGRectMake((kScreenWidth - 300 * kIphoneSizeScale) / 2, 63 * kIphoneSizeScale, 300 * kIphoneSizeScale, 300 * kIphoneSizeScale);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor grayColor];
    
    DJButton *cancelBtn = [DJButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:MOLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [cancelBtn setButtonWithStateColor];
    [cancelBtn addTarget:self action:@selector(uploadPhotoCancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.cancel = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = _cancel;
    
    self.contentView = [[DJScaleMoveView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kFunctionPanelHeight - 64)];
    self.contentView.maskRect = self.maskRect;
    [self.view addSubview:_contentView];
    [self.contentView resetImage:self.uploadImage];
    
    self.photoRule = [[UIImageView alloc] initWithFrame:_contentView.frame];
    self.photoRule.userInteractionEnabled = NO;
    [self.view addSubview:_photoRule];
    
    UIImageView *coverFrame =[[UIImageView alloc]initWithFrame:self.maskRect];
    coverFrame.image = [UIImage imageNamed:@"CreationDejaPhotoFrame"];
    UIImageView *coverTop =[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - self.maskRect.size.width) / 2, 0, self.maskRect.size.width, coverFrame.frame.origin.y)];
    [coverTop setBackgroundColor:[UIColor colorFromHexString:@"ffffff" alpha:0.4]];
    UIImageView *coverLeft =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (self.view.frame.size.width - self.maskRect.size.width) / 2, _contentView.frame.size.height)];
    [coverLeft setBackgroundColor:[UIColor colorFromHexString:@"ffffff" alpha:0.4]];
    UIImageView *coverRight =[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - (self.view.frame.size.width - self.maskRect.size.width) / 2, 0,(kScreenWidth - self.maskRect.size.width) / 2, _contentView.frame.size.height)];
    [coverRight setBackgroundColor:[UIColor colorFromHexString:@"ffffff" alpha:0.4]];
    UIImageView *coverBottom =[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - self.maskRect.size.width) / 2, self.maskRect.size.height + coverFrame.frame.origin.y, self.maskRect.size.width, _contentView.frame.size.height - self.maskRect.size.height)];
    [coverBottom setBackgroundColor:[UIColor colorFromHexString:@"ffffff" alpha:0.4]];
    [_photoRule addSubview:coverFrame];
    [_photoRule addSubview:coverTop];
    [_photoRule addSubview:coverLeft];
    [_photoRule addSubview:coverRight];
    [_photoRule addSubview:coverBottom];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _contentView.frame.size.height, self.view.frame.size.width, kFunctionPanelHeight)];
    [self.view addSubview:bottomView];
    bottomView.backgroundColor = [UIColor colorFromHexString:@"262729"];
    
    UIButton *goTakePhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 58)];
    goTakePhoto.center = CGPointMake(20 + goTakePhoto.frame.size.width / 2, bottomView.frame.size.height / 2);
    [bottomView addSubview:goTakePhoto];
    
    [goTakePhoto setTitle:MOLocalizedString(@"Retake", @"") forState:UIControlStateNormal];
    [goTakePhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goTakePhoto setTitleColor:[DJCommonStyle ColorRed] forState:UIControlStateHighlighted];
    goTakePhoto.titleLabel.font = [DJFont fontOfSize:20];
    [goTakePhoto addTarget:self action:@selector(gotoTakePhoto)forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *use = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 58)];
    [bottomView addSubview:use];
    use.center = CGPointMake(bottomView.frame.size.width / 2, bottomView.frame.size.height / 2);
    [use setTitleColor:[DJCommonStyle ColorRed] forState:UIControlStateNormal];
    [use setTitle:MOLocalizedString(@"SELECT", @"") forState:UIControlStateNormal];
    [use setTitleColor:[UIColor colorFromHexString:@"ff8878"] forState:UIControlStateHighlighted];
    use.titleLabel.font = [DJFont mediumHelveticaFontOfSize:24];
    [use addTarget:self action:@selector(usePhotoForDejaMachine) forControlEvents:UIControlEventTouchUpInside];
}

-(void)gotoTakePhoto{
    if ([self.delegate respondsToSelector:@selector(uploadPhotoViewControllerDidClickTakePhoto:)]) {
        [self.delegate uploadPhotoViewControllerDidClickTakePhoto:self];
    }
}

- (void)uploadPhotoCancel {
    if ([self.delegate respondsToSelector:@selector(uploadPhotoViewControllerDidClickCancel:)]) {
        [self.delegate uploadPhotoViewControllerDidClickCancel:self];
    }
}

-(void)usePhotoForDejaMachine{
    if ([self.delegate respondsToSelector:@selector(uploadPhotoViewController:uploadPhoto:)]) {
        [self.delegate uploadPhotoViewController:self uploadPhoto:[self.contentView clipImageByMaskRect]];
    }
}


@end
