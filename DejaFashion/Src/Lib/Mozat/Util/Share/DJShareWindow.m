//
//  DJShareWindow.m
//  DejaFashion
//
//  Created by Kevin Lin on 10/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJShareWindow.h"
#import "DJShareEntry.h"
#import "Reachability.h"

static DJShareWindow *currentShareWindow;

@interface DJShareWindow()

@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, copy) void(^completion)(DJShareEntry *);

@end

@implementation DJShareWindow

- (instancetype)initWithEntries:(NSArray *)entries
{
    if (self = [super init]) {
        self.entries = entries;
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.bgView.alpha = 0;
    [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewDidTap)]];
    [self addSubview:self.bgView];
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 225)];
    self.mainView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self addSubview:self.mainView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
    titleLabel.backgroundColor = [UIColor colorFromHexString:@"ebebeb"];
    titleLabel.text = @"SHARE VIA";
    titleLabel.textColor = [UIColor colorFromHexString:@"818181"];
    titleLabel.font = [DJFont contentItalicFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainView addSubview:titleLabel];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height,
                                                                              self.mainView.frame.size.width,
                                                                              140)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.mainView addSubview:scrollView];
    
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollView.frame.size.height + scrollView.frame.origin.y, self.mainView.frame.size.width, 0.5)];
    borderView.backgroundColor = [UIColor colorFromHexString:@"c4c4c4"];
    [self.mainView addSubview:borderView];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, borderView.frame.origin.y, self.mainView.frame.size.width, 55)];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [DJFont contentFontOfSize:14];
    [cancelBtn setTitleColor:[UIColor colorFromHexString:@"414141"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorFromHexString:@"f81f34"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(bgViewDidTap) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:cancelBtn];
    
    float btnX = 0;
    float btnWidth = 58;
    float spacing = 25;
    if ((self.entries.count <= 3 && self.frame.size.width <= 320) || (self.entries.count <= 4 && self.frame.size.width > 320)) {
        btnX = (scrollView.frame.size.width - self.entries.count * btnWidth - (self.entries.count - 1) * spacing) / 2;
    }else{
        btnX = 20;
    }
    
    for (int i = 0; i < self.entries.count; i++) {
        DJShareEntry *entry = self.entries[i];
        UIButton *entryBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, (scrollView.frame.size.height - btnWidth) / 2 - 11, btnWidth, btnWidth)];
        entryBtn.tag = i;
        [entryBtn setBackgroundImage:entry.icon forState:UIControlStateNormal];
        [entryBtn addTarget:self action:@selector(entryBtnDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:entryBtn];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(btnX - 5, entryBtn.frame.size.height + entryBtn.frame.origin.y + 8, btnWidth + 10, 30)];
        name.font = [DJFont contentFontOfSize:12];
        name.lineBreakMode = NSLineBreakByWordWrapping;
        name.numberOfLines = 2;
        name.textAlignment = NSTextAlignmentCenter;
        name.textColor = [UIColor colorFromHexString:@"818181"];
        name.text = entry.labelName;
        [scrollView addSubview:name];
        btnX += spacing + btnWidth;
    }
    scrollView.contentSize = CGSizeMake(btnX, scrollView.frame.size.height);
}

- (void)bgViewDidTap
{
    self.hidden = YES;
}

- (void)entryBtnDidTap:(UIButton *)entryBtn
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Turn on cellular data or use Wi-Fi to access data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        self.hidden = YES;
        return;
    }
    DJShareEntry *entry = self.entries[entryBtn.tag];
    [entry share];
    if (self.completion) {
        self.completion(entry);
        self.completion = nil;
    }
    self.hidden = YES;
}

- (void)setHidden:(BOOL)hidden
{
    if (hidden) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.bgView.alpha = 0;
            self.mainView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [super setHidden:hidden];
            if (self.completion) {
                self.completion(nil);
                self.completion = nil;
            }
        }];
    }
    else {
        [super setHidden:hidden];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.bgView.alpha = 1;
            self.mainView.transform = CGAffineTransformMakeTranslation(0, -self.mainView.frame.size.height);
        } completion:nil];
    }
}


+ (void)shareWithAugment:(ShareParameter *)parameter
                   entries:(NSArray *)entries
      showInViewController:(UIViewController *)vc
                completion:(void (^)(DJShareEntry *))completion


//+ (void)shareWithThumbnail:(UIImage *)image
//                  imageUrl:(NSString *)imageUrl
//                     title:(NSString *)title
//               contentText:(NSString *)text
//                      link:(NSString *)link
//                 shortLink:(NSString *)shortLink
//                   entries:(NSArray *)entries
//      showInViewController:(UIViewController *)vc
//                completion:(void (^)(DJShareEntry *))completion
{
    
    currentShareWindow = [[DJShareWindow alloc] initWithEntries:entries];
    currentShareWindow.completion = completion;
    currentShareWindow.hidden = NO;
    
    for (DJShareEntry *entry in entries) {
        entry.parameter = parameter;
//        entry.thumbnail = image;
//        entry.imageUrl = imageUrl;
//        entry.title = title;
//        entry.contentText = text;
//        entry.link = link;
//        entry.shortLink = shortLink;
        entry.showInViewController = vc;
    }
}


@end
