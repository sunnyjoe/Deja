//
//  DJMessageEntry.m
//  DejaFashion
//
//  Created by Sun lin on 12/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "DJMessageEntry.h"
#import <MessageUI/MessageUI.h>

@interface DJMessageEntry()<MFMessageComposeViewControllerDelegate>
@end

@implementation DJMessageEntry

- (UIImage *)icon
{
    return [UIImage imageNamed:@"SmsIcon"];
}

- (void)share:(UIWindow *)window
{
    
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
        smsController.navigationBar.barStyle = UIBarStyleDefault;
        smsController.body = [NSString stringWithFormat:@"%@...%@", self.parameter.messageText, self.parameter.link];
        smsController.view.backgroundColor = [UIColor whiteColor];
        smsController.messageComposeDelegate = self;
        [self.showInViewController presentViewController:smsController animated:YES completion:nil];
    }
    else
    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:MOLocalizedString(@"Cannot send SMS from this device.", @"")
//                                                       delegate:nil
//                                              cancelButtonTitle:MOLocalizedString(@"OK", @"")
//                                              otherButtonTitles:nil];
//        [alert show];
    }
}

- (NSString *)name
{
    return @"message";
}

-(NSString *)labelName{
    return @"Message";
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    if(result==MessageComposeResultSent)
    {

    }
    else if(result==MessageComposeResultCancelled)
    {
        
    }
    else if(result==MessageComposeResultFailed)
    {
    
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
