//
//  DJLuaPatchHandler.m
//  WaxPatch
//
//  Created by Sun lin on 20/8/15.
//  Copyright (c) 2015 dianping.com. All rights reserved.
//

#import "DJLuaPatchHandler.h"
//#import "lauxlib.h"
//#import "wax.h"
//#import "ZipArchive.h"

@implementation DJLuaPatchHandler

static DJLuaPatchHandler *sharedInstance;
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
    }
    
    return self;
}


-(void) useLuaPatch
{
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    NSString *luaFolder = [[doc stringByAppendingPathComponent:@"lua/"] stringByAppendingPathComponent:version];
//    NSString *pp = [[NSString alloc ] initWithFormat:@"%@/?.lua;%@/?/init.lua;", luaFolder, luaFolder];
//    setenv(LUA_PATH, [pp UTF8String], 1);
//    
//    NSString *initlua = [luaFolder stringByAppendingPathComponent:@"patch.lua"];
//    if([[NSFileManager defaultManager] fileExistsAtPath:initlua])
//    {
//        wax_start("patch", nil);
//    }
}

-(void) downLoadLuaPatch:(NSString *)patchUrl
{
    
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *luaFolder = [[doc stringByAppendingPathComponent:@"lua/"] stringByAppendingPathComponent:@""];
//    NSString *initlua = [luaFolder stringByAppendingPathComponent:@"patch.lua"];
//    if([[NSFileManager defaultManager] fileExistsAtPath:initlua])
//    {
//        return;
//    }
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        // you probably want to change this url before run
//        NSURL *url = [NSURL URLWithString:patchUrl];
//        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:NULL error:NULL];
//        if(data) {
//            NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//            
//            NSString *patchZip = [doc stringByAppendingPathComponent:@"patch.zip"];
//            [data writeToFile:patchZip atomically:YES];
//            
//            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//            NSString *luaFolder = [[doc stringByAppendingPathComponent:@"lua/"] stringByAppendingPathComponent:version];
//            
//            ZipArchive *zip = [[ZipArchive alloc] init];
//            BOOL success = [zip UnzipOpenFile:patchZip];
//            if(success)
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:luaFolder error:NULL];
//                [[NSFileManager defaultManager] createDirectoryAtPath:luaFolder withIntermediateDirectories:YES attributes:nil error:NULL];
//                [zip UnzipFileTo:luaFolder overWrite:YES];
//                [self useLuaPatch];
//            }
//            
//            [[NSFileManager defaultManager] removeItemAtPath:patchZip error:NULL];
//        }
//    });
}

@end
