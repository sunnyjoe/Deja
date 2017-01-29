//
//  DJFBShareEntry.m
//  DejaFashion
//
//  Created by Kevin Lin on 10/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJFBShareEntry.h"
#import <Social/Social.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface DJFBShareEntry()<FBSDKSharingDelegate>

@property (nonatomic, weak) UIView *view;

@property (nonatomic, weak) FBSDKShareDialog *dialog;

@end


@implementation DJFBShareEntry

- (UIImage *)icon
{
    return [UIImage imageNamed:@"FBFollowIcon"];
}

- (void)share:(UIWindow *)window
{
    UIViewController *topViewController = window.rootViewController;
    if (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    self.view = topViewController.view;
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:self.parameter.link];
    content.contentTitle = self.parameter.facebookTitle;
    content.contentDescription = self.parameter.facebookText;
    content.imageURL = [NSURL URLWithString:self.parameter.imageUrl];
    FBSDKShareDialog *dialog = [FBSDKShareDialog new];
    dialog.fromViewController = topViewController;
    [dialog setMode:FBSDKShareDialogModeFeedBrowser];
    dialog.delegate = self;
    [dialog setShareContent:content];
    [dialog show];
    
    self.dialog = dialog;
}


- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    if ([self.delegate respondsToSelector:@selector(sharedCompleted:)]) {
        if (self.dialog.mode == FBSDKShareDialogModeAutomatic) {
            if (results[@"postId"]) {
                [self.delegate sharedCompleted:YES];
                [MBProgressHUD showHUDAddedTo:self.view text:MOLocalizedString(@"Shared Successfully", @"")  animated:YES];
            }else {
                [self.delegate sharedCompleted:NO];
            }
        }else {
            if (results.count > 0)
            {
                [self.delegate sharedCompleted:YES];
                [MBProgressHUD showHUDAddedTo:self.view text:MOLocalizedString(@"Shared Successfully", @"")  animated:YES];
            }
        }
    }
}


- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(sharedCompleted:)]) {
        [self.delegate sharedCompleted:NO];
        [MBProgressHUD showHUDAddedTo:self.view text:MOLocalizedString(@"Shared Failed", @"")  animated:YES];
    }
}


- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    if ([self.delegate respondsToSelector:@selector(sharedCompleted:)]) {
        [self.delegate sharedCompleted:NO];
        [MBProgressHUD showHUDAddedTo:self.view text:MOLocalizedString(@"Shared Canceled", @"")  animated:YES];
    }
}

- (NSString *)name
{
    return @"fb";
}

-(NSString *)labelName{
    return @"Facebook";
}
@end
