//
//  DJReportDeviceTokenNetTask.h
//  DejaFashion
//
//  Created by Sun lin on 9/3/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//

#import "DJHTTPNetTask.h"

@interface DJReportDeviceTokenNetTask : DJHTTPNetTask

@property (nonatomic, strong) NSString *deviceToken;
@end
