//
//  MOBasicViewController.h
//  Mozat
//
//  Created by sunlin on 22/10/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOBasicViewController : UIViewController

-(NSArray *)notificationNames;
-(void)didReceiveNotification:(NSNotification *)notification;

@end
