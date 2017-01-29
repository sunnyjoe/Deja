//
//  UIAlertView+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DJAlertView+Block.h"
#import <objc/runtime.h>

static char DISMISS_IDENTIFER;
static char CANCEL_IDENTIFER;

@implementation DJAlertView (Block)

@dynamic cancelBlock;
@dynamic dismissBlock;

- (void)setDismissBlock:(DismissBlock)dismissBlock
{
    objc_setAssociatedObject(self, &DISMISS_IDENTIFER, dismissBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DismissBlock)dismissBlock
{
    return objc_getAssociatedObject(self, &DISMISS_IDENTIFER);
}

- (void)setCancelBlock:(CancelBlock)cancelBlock
{
    objc_setAssociatedObject(self, &CANCEL_IDENTIFER, cancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CancelBlock)cancelBlock
{
    return objc_getAssociatedObject(self, &CANCEL_IDENTIFER);
}


+ (DJAlertView*) alertViewWithTitle:(NSString*) title
                    message:(NSString*) message 
          cancelButtonTitle:(NSString*) cancelButtonTitle
          otherButtonTitles:(NSArray*) otherButtons
                  onDismiss:(DismissBlock) dismissed                   
                   onCancel:(CancelBlock) cancelled {
        
    DJAlertView *alert = [[DJAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:(id<DJAlertViewDelegate>)[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitlesArray:otherButtons];
    
    [alert setDismissBlock:dismissed];
    [alert setCancelBlock:cancelled];
    
    [alert show];
    return alert;
}

+ (DJAlertView*) alertViewWithTitle:(NSString*) title
                    message:(NSString*) message {
    
    return [DJAlertView alertViewWithTitle:title
                                   message:message 
                         cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")];
}

+ (DJAlertView*) alertViewWithTitle:(NSString*) title
                    message:(NSString*) message
          cancelButtonTitle:(NSString*) cancelButtonTitle {
    DJAlertView *alert = [[DJAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles: nil];
    [alert show];
    return alert;
}


+ (void)alertView:(DJAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
		if (alertView.cancelBlock) {
            alertView.cancelBlock();
        }
	}
    else
    {
        if (alertView.dismissBlock) {
            alertView.dismissBlock((int)buttonIndex - 1); // cancel button is button 0
        }
    }
}

@end