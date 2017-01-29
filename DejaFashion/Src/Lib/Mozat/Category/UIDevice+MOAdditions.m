//
//  UIDevice+MOAdditions.m
//  Mozat
//
//  Created by sunlin on 11/10/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "UIDevice+MOAdditions.h"
#include <sys/sysctl.h>

@implementation UIDevice (MOAdditions)

+(BOOL)isSimulator{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	if( [platform hasPrefix:@"x86_64"])
	{
		return YES;
	}
	return NO;
}
@end
