
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GMSMapView+VV.h"

@interface Place : NSObject

@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

-(NSDictionary *)toDict;
-(BOOL)isEquels:(Place *)place;
+(Place *) parsePlaceFromJson:(NSDictionary *)json;
+(Place *) parsePlaceFromGMSPlace:(GMSPlace *)gmsPlace;
@end
