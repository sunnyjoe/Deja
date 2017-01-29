//
//  DJShareWindow.h
//  DejaFashion
//
//  Created by Kevin Lin on 10/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJFBShareEntry.h"
#import "DJTwitterShareEntry.h"
#import "DJInstagramShareEntry.h"

@interface DJShareWindow : UIWindow

//+ (void)shareWithThumbnail:(UIImage *)image
//                  imageUrl:(NSString *)imageUrl
//                     title:(NSString *)title
//               contentText:(NSString *)text
//                      link:(NSString *)link
//                 shortLink:(NSString *)shortLink
//                   entries:(NSArray *)entries
//      showInViewController:(UIViewController *)vc
//                completion:(void (^)(DJShareEntry *))completion;
+ (void)shareWithAugment:(ShareParameter *)parameter
                 entries:(NSArray *)entries
    showInViewController:(UIViewController *)vc
              completion:(void (^)(DJShareEntry *))completion;
@end
