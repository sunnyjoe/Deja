//
//  MOBasicViewController.m
//  Mozat
//
//  Created by sunlin on 22/10/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "MOBasicViewController.h"

@interface MOBasicViewController ()

@end

@implementation MOBasicViewController

- (instancetype)init{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    NSArray *notificationNames = [self notificationNames];
    for(NSString *notificationName in notificationNames){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotification:) name:notificationName object:nil];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)onReceiveNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didReceiveNotification:notification];
    });
    
}

-(NSArray *)notificationNames
{
    return [NSArray array];
}

-(void)didReceiveNotification:(NSNotification *)notification
{
    
}

@end
