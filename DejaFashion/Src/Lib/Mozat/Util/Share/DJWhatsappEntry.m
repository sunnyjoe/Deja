//
//  DJWhatsappEntry.m
//  DejaFashion
//
//  Created by Sun lin on 12/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

#import "DJWhatsappEntry.h"

@implementation DJWhatsappEntry

- (UIImage *)icon
{
    return [UIImage imageNamed:@"WhatsappIcon"];
}

- (void)share:(UIWindow *)window
{
    if (![[UIApplication sharedApplication] openUrlFormatIfCan:@"whatsapp://send?text=%@...%@", self.parameter.whatsappText.urlEncode2, self.parameter.link.urlEncode2])
    {
        [MBProgressHUD showHUDAddedTo:self.showInViewController.view
                                 text:MOLocalizedString(@"You haven't installed Whatsapp.", @"")
                             animated:YES];
    }
}

- (NSString *)name
{
    return @"whatsapp";
}

-(NSString *)labelName{
    return @"Whatsapp";
}
@end
