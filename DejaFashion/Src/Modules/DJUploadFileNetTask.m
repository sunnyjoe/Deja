//
//  DJUploadFileNetTask.m
//  DejaFashion
//
//  Created by Sun lin on 11/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJUploadFileNetTask.h"

@implementation DJUploadFileNetTask

- (NSString *)uri
{
    return @"deja-fashion/upload";
}

- (DJHTTPNetTaskMethod)method
{
    return DJHTTPNetTaskPost;
}

- (NSDictionary *)query
{
    return nil;
}

- (NSDictionary *)files
{
    if(self.data)
    {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:self.data forKey:@"file"];
        return dict;
    }
    return nil;
}

- (void)didResponseJSON:(NSDictionary *)response
{
    self.fileUrl = [response objectForKey:@"url"];
}

- (void)didFail:(NSError *)error
{

}
@end
