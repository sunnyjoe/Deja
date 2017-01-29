//
//  CALayer+MOAdditions.h
//  DejaFashion
//
//  Created by Sun lin on 27/11/14.
//  Copyright (c) 2014 Mozat. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (MOAdditions)

-(void)removeAllSubLayers;
-(UIImage *)getImageFromLayer;
@end
