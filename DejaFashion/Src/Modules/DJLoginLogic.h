//
//  DJLoginLogic.h
//  
//
//  Created by DanyChen on 16/9/15.
//
//

#import <Foundation/Foundation.h>

@protocol ThirdPartyLoginDelegate <NSObject>
@optional
-(void)thirdPartyLoginDidCanceled;
-(void)thirdPartyLoginError;
-(void)thirdPartyLoginDidSuccess;

-(void)thirdPartyBindDidCanceled;
-(void)thirdPartyBindDidError;
-(void)thirdPartyBindDidSuccess;
@end

@interface DJLoginLogic : NSObject
+ (instancetype)instance;

-(void)facebookLoginWithSource;
-(void)bindFacebook;

-(void)setContainerView:(UIView *)parentView;

+(void)clearUserData;

-(void)addDelegate: (id<ThirdPartyLoginDelegate>)delegate;

@end
