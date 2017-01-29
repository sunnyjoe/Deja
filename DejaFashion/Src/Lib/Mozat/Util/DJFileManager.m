//
//  DJFileManager.m
//  DejaFashion
//
//  Created by Sunny XiaoQing on 4/3/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJFileManager.h"

@implementation DJFileManager
+ (BOOL)isFileExist:(NSString *)name {
    if (!name) {
        return NO;
    }
    NSString *newName = [name stringByDeletingPathExtension];
    NSString *extension = [name pathExtension];
    
    /** First, try to find it in the project BUNDLE (this was HARD CODED at compile time; can never be changed!) */
    NSString *pathToFileInBundle = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    if( bundle != nil ){
        pathToFileInBundle = [bundle pathForResource:newName ofType:extension];
        if (pathToFileInBundle) {
            return YES;
        }
    }
    
    /** Second, try to find it in the Documents folder (this is where Apple expects you to store custom files at runtime) */
    NSString* pathToFileInDocumentsFolder = nil;
    NSString* pathToDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    if( pathToDocumentsFolder != nil )
    {
        pathToFileInDocumentsFolder = [[pathToDocumentsFolder stringByAppendingPathComponent:newName] stringByAppendingPathExtension:extension];
        if( [[NSFileManager defaultManager] fileExistsAtPath:pathToFileInDocumentsFolder])
            return YES;
        else
            pathToFileInDocumentsFolder = nil; // couldn't find a file there
    }
    
    if(pathToFileInBundle == nil && pathToFileInDocumentsFolder == nil ){
        return NO;
    }else {
        return YES;
    }
    
}

+(NSString *)getStringFromTxtFile:(NSString *)fileName{
    NSString *pathToFileInBundle = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    if( bundle != nil ){
        pathToFileInBundle = [bundle pathForResource:fileName ofType:@"txt"];
        if (pathToFileInBundle) {
            NSString *strs = [NSString stringWithContentsOfFile:pathToFileInBundle encoding:NSUTF8StringEncoding error:nil];
            return strs;
        }
    }
    return nil;
}

@end
