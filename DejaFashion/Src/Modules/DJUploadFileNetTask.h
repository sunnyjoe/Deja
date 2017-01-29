//
//  DJUploadFileNetTask.h
//  DejaFashion
//
//  Created by Sun lin on 11/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJHTTPNetTask.h"

@interface DJUploadFileNetTask : DJHTTPNetTask

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *fileUrl;
@end
