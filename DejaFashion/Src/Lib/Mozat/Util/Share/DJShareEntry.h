//
//  DJShareEntry.h
//  DejaFashion
//
//  Created by Kevin Lin on 10/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DJShareEntryDelegate <NSObject>

-(void)sharedCompleted:(BOOL)success;

@end


@interface ShareParameter : NSObject

@property (nonatomic, strong) UIImage *thumb;//small image
@property (nonatomic, strong) UIImage *image;//large image
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *thumbUrl;
//@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) NSString *summary;//short text
//@property (nonatomic, strong) NSString *text;//long text
@property (nonatomic, strong) NSString *link;
//@property (nonatomic, strong) NSString *shortLink;

@property (nonatomic, strong) NSString *source;
//@property (nonatomic, strong) NSDictionary *placeholder;

@property (nonatomic, strong) NSString *facebookTitle;
@property (nonatomic, strong) NSString *facebookText;

@property (nonatomic, strong) NSString *wechatTitle;
@property (nonatomic, strong) NSString *wechatText;

@property (nonatomic, strong) NSString *whatsappTitle;
@property (nonatomic, strong) NSString *whatsappText;

@property (nonatomic, strong) NSString *messageTitle;
@property (nonatomic, strong) NSString *messageText;

@property (nonatomic, strong) NSString *momentsTitle;
@property (nonatomic, strong) NSString *momentsText;


@end


@interface DJShareEntry : NSObject

@property (weak, nonatomic) id<DJShareEntryDelegate> delegate;
@property (nonatomic, strong) UIViewController *showInViewController;
@property (nonatomic, strong) ShareParameter *parameter;

- (UIImage *)icon;
- (void)share;
- (void)share:(UIWindow *)window;
- (NSString *)name;
-(NSString *)labelName;
@end
