//
//  NSString+MOAdditions.m
//  DejaFashion
//
//  Created by Sun lin on 17/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "NSString+Mozat.h"

@implementation NSString (Mozat)

+(NSString *)stringWithInt:(NSInteger)intValue{
    return [NSString stringWithFormat:@"%ld", (long)intValue];
}
+(NSString *)stringWithLongLong:(SInt64)longlongValue{
    return [NSString stringWithFormat:@"%lld", longlongValue];
}
+(NSString *)stringWithUnsignLongLong:(UInt64)longlongValue{
    return [NSString stringWithFormat:@"%lld", longlongValue];
}
- (NSString *) urlEncode2
{
    NSString * encoded = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                               (CFStringRef)self,
                                                                                               NULL,
                                                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                               kCFStringEncodingUTF8 ));
	   
    return encoded;
}

-(NSString *)urlDecode2
{
    NSString *decoded = decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
    return decoded;
}


- (NSString *) urlEncode
{
    NSString * encoded = [self stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    return encoded;
}

-(NSString *)urlDecode
{
    NSString *decoded = [self stringByRemovingPercentEncoding];
    return decoded;
}

- (CGSize) sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGSize theSize;
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    if ((lineBreakMode & NSLineBreakByTruncatingTail) == NSLineBreakByTruncatingTail) {
        options = options | NSStringDrawingTruncatesLastVisibleLine;
    }
    CGRect rect = [self boundingRectWithSize:maxSize options:options attributes:@
                   {
                   NSFontAttributeName: font
                   } context:nil];
    theSize = rect.size;
    // zhenling: boundingRectWithSize is buggy. some times return wrong width value. but the height seems correct
    if (rect.size.width > maxSize.width) {
        theSize = CGSizeMake(maxSize.width, rect.size.height);
    }
    return CGSizeMake(ceil(theSize.width), ceil(theSize.height));
}

- (BOOL)isInteger{
    if ([self rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        return YES;
    }
    return NO;
//    if([self intValue] != 0) {
//        return true;
//    } else if([self isEqualToString:@"0"]) {
//        return true;
//    } else {
//        return false;
//    }
}
@end
