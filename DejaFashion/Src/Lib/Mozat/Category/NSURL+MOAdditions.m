//
//  NSURL+MOAdditions.m
//  DejaFashion
//
//  Created by DanyChen on 8/10/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

#import "NSURL+MOAdditions.h"
#define KDJImageQualityVeryHigh     (int)(300 * [UIScreen mainScreen].scale)
#define KDJImageQualityHigh         (int)(260 * [UIScreen mainScreen].scale)
#define KDJImageQualityMedium       (int)(200 * [UIScreen mainScreen].scale)
#define KDJImageQualityLow          (int)(140 * [UIScreen mainScreen].scale)
#define KDJImageQualityVeryLow      (int)(80 * [UIScreen mainScreen].scale)
@implementation NSURL (MOAdditions)

+(NSURL *)imageUrlWithQuality:(NSString *)url quality:(DJImageQuality)quality {
    int width = 0;
    if (url.length) {
        switch (quality) {
            case DJImageQualityVeryHigh:
                width = KDJImageQualityVeryHigh;
                break;
            case DJImageQualityHigh:
                width = KDJImageQualityHigh;
                break;
            case DJImageQualityMedium:
                width = KDJImageQualityMedium;
                break;
            case DJImageQualityLow:
                width = KDJImageQualityLow;
                break;
            case DJImageQualityVeryLow:
                width = KDJImageQualityVeryLow;
                break;
            default:
                width = KDJImageQualityVeryHigh;
                break;
        }
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d.jpg", url, width]];
    }
    return nil;
}


- (BOOL)isMatch:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSTextCheckingResult *res = [regex firstMatchInString:self.absoluteString options:0 range:NSMakeRange(0, self.absoluteString.length)];
    return res != nil;
}

- (BOOL)isiTunesURL {
    return [self isMatch:@"\\/\\/itunes\\.apple\\.com\\/"];
}

@end
