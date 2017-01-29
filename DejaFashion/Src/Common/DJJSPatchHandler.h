//  Created by Sun lin on 20/8/15.
//  Copyright (c) 2015 dianping.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJJSPatchHandler : NSObject

+ (DJJSPatchHandler *)instance;


-(void) useJSPatch;
-(void) downLoadJSPatch:(NSString *)patchUrl version: (NSString *)version;
@end
