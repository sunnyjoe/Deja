//
//  DJReportDilogsNetTask.h
//  DejaFashion
//
//  Created by Sun lin on 22/12/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import "DJHTTPNetTask.h"

@interface DJReportDilogsNetTask : DJHTTPNetTask
@property(nonatomic, strong)NSArray *waitingForUpload;

@end
