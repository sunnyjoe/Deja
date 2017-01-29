//
//  DJInstagramShareEntry.m
//  DejaFashion
//
//  Created by Kevin Lin on 10/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJInstagramShareEntry.h"
#import "DJAlertView.h"

@interface DJInstagramShareEntry ()

@property (nonatomic, strong) UIDocumentInteractionController *docController;

@end

@implementation DJInstagramShareEntry

- (UIImage *)icon
{
    return [UIImage imageNamed:@"InstagramFollowIcon"];
}

- (void)share:(UIWindow *)window
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[[DJAlertView alloc] initWithTitle:@""
                                    message:MOLocalizedString(@"Please install Instagram to share.", @"")
                                   delegate:nil
                          cancelButtonTitle:MOLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
        return;
    }
    
    if (self.parameter.thumb.size.width != self.parameter.thumb.size.height) {
        float imageSize = self.parameter.thumb.size.width > self.parameter.thumb.size.height ? self.parameter.thumb.size.width : self.parameter.thumb.size.height;
        CGRect rect = CGRectMake(0, 0, imageSize, imageSize);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx,rect);
        [self.parameter.thumb drawInRect:CGRectMake((imageSize - self.parameter.thumb.size.width) / 2, (imageSize - self.parameter.thumb.size.height) / 2,
                                          self.parameter.thumb.size.width, self.parameter.thumb.size.height)];
        self.parameter.thumb = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (self.parameter.thumb.size.width < 612) {
        CGSize size = CGSizeMake(612, 612);
        UIGraphicsBeginImageContext(size);
        [self.parameter.thumb drawInRect:CGRectMake(0, 0, size.width, size.height)];
        self.parameter.thumb = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSString *jpgPath= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/instagram_share.igo"];
    [UIImageJPEGRepresentation(self.parameter.thumb, 1.0) writeToFile:jpgPath atomically:YES];
    NSURL *imageFileUrl = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
    
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:imageFileUrl];
    self.docController.UTI = @"com.instagram.exclusivegram";
    //    self.docController.annotation = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@(%@) - %@",
    //                                                                        self.title, self.link, self.text]
    self.docController.annotation = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ %@",
                                                                        self.parameter.messageText, @"Download Deja now! @dejafashion"]
                                                                forKey:@"InstagramCaption"];
    
    UIViewController *topViewController = window.rootViewController;
    if (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    [self.docController presentOpenInMenuFromRect:topViewController.view.bounds
                                           inView:topViewController.view
                                         animated:YES];
}

- (NSString *)name
{
    return @"ins";
}

-(NSString *)labelName{
    return @"Instagram";
}
@end
