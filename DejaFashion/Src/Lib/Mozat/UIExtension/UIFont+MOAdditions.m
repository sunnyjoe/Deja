//
//  UIFont+MOAdditions.m
//  Mozat
//
//  Created by Yixiang Lu on 3/3/10.
//  Copyright 2010 Mozat. All rights reserved.
//

#import "UIFont+MOAdditions.h"


@implementation UIFont(MOAdditions)

-(int)fullHeight
{
	return self.ascender - self.descender;
}

@end
