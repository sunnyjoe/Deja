//
//  DJWXChatEntry.m
//  DejaFashion
//
//  Created by Sun lin on 11/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "DJWXChatEntry.h"
#import "WXApi.h"

@implementation DJWXChatEntry

- (UIImage *)icon
{
    return [UIImage imageNamed:@"WXicon"];
}

- (void)share:(UIWindow *)window
{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]])
    {
        [MBProgressHUD showHUDAddedTo:self.showInViewController.view text:MOLocalizedString(@"You haven't installed Wechat.", @"")  animated:YES];
        return;
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.parameter.link;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.parameter.wechatTitle;
    message.description = self.parameter.wechatText;
    message.mediaObject = ext;
    message.messageExt = nil;
    message.messageAction = nil;
    message.mediaTagName = @"tag_name";
    [message setThumbImage:self.parameter.thumb];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.scene = WXSceneSession;
    req.message = message;
    [WXApi sendReq:req];
    
}

- (NSString *)name
{
    return @"weixin";
}

-(NSString *)labelName{
    return @"Wechat";
}
@end
