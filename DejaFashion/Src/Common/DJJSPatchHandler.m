//  Created by Sun lin on 20/8/15.
//  Copyright (c) 2015 dianping.com. All rights reserved.
//

#import "DJJSPatchHandler.h"
#import "JPEngine.h"

@interface DJJSPatchHandler()

@property (nonatomic, strong) NSString *scriptPath;
@property (nonatomic, strong) NSString *dir;
@property (nonatomic, strong) NSString *version;

@end


@implementation DJJSPatchHandler

static DJJSPatchHandler *sharedInstance;
+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

-(id)init
{
    // TODO (JIAOQING) CHANGED FROM singleton class to non
    NSAssert(!sharedInstance, @"This should be a singleton class.");
    self = [super init];
    if(self)
    {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        self.dir = [doc stringByAppendingPathComponent:@"jspatch"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.dir])
            [[NSFileManager defaultManager] createDirectoryAtPath:self.dir withIntermediateDirectories:NO attributes:nil error:nil];
        self.scriptPath = [self patchPathOfVersion:self.version];
    }
    
    return self;
}


-(void) useJSPatch
{
    [JPEngine startEngine];
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:self.scriptPath encoding:NSUTF8StringEncoding error:nil];
    if (script.length) {
        [JPEngine evaluateScript:script];
    }
}

-(void) downLoadJSPatch:(NSString *)patchUrl version: (NSString *)version
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // you probably want to change this url before run
        NSURL *url = [NSURL URLWithString:patchUrl];
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:NULL error:NULL];
        if(data.length) {
            NSError * error = nil;
            BOOL success = [data writeToFile:[self patchPathOfVersion:version] options:NSDataWritingAtomic error:&error];
            NSLog(@"Success = %d, error = %@", success, error);
            if ([version isEqualToString:self.version]) {
                [self useJSPatch];
            }
        }
    });
}

-(NSString *)patchPathOfVersion: (NSString *)version {
    return [self.dir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.js", version]];
}

@end
