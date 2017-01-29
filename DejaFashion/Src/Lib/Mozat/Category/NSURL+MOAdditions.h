//
//  NSURL+MOAdditions.h
//  DejaFashion
//
//  Created by DanyChen on 8/10/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DJImageQualityVeryHigh,
    DJImageQualityHigh,
    DJImageQualityMedium,
    DJImageQualityLow,
    DJImageQualityVeryLow
} DJImageQuality;

@interface NSURL (MOAdditions)

+(NSURL *)imageUrlWithQuality: (NSString *)url quality: (DJImageQuality)quality;

- (BOOL)isiTunesURL;
@end
