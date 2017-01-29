//
//  NSString+MOAdditions.h
//  DejaFashion
//
//  Created by Sun lin on 17/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Mozat)

+(NSString *)stringWithInt:(NSInteger)intValue;
+(NSString *)stringWithLongLong:(SInt64)longlongValue;
+(NSString *)stringWithUnsignLongLong:(UInt64)longlongValue;


- (CGSize) sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (BOOL)isInteger;

- (NSString *) urlEncode;
- (NSString *) urlEncode2;

-(NSString *)urlDecode;
-(NSString *)urlDecode2;



@end
