

#import <Foundation/Foundation.h>
#import "Place.h"

#define NOTIFY_LOCATION_INITIATE @"NOTIFY_LOCATION_INITIATE"
#define NOTIFY_LOCATION_AUTH_ALLOW @"NOTIFY_LOCATION_AUTH_ALLOW"
#define NOTIFY_LOCATION_AUTH_DENIED @"NOTIFY_LOCATION_AUTH_DENIED"
#define NOTIFY_LOCATION_UPDATE @"NOTIFY_LOCATION_UPDATE"

@interface LocationManager : NSObject

+ (instancetype)sharedInstance;
@property(nonatomic, strong) CLLocation *currentLocation;
@property(nonatomic, strong) CLLocationManager *locationManager;


-(void) geocodeAddress:(CLLocationCoordinate2D)location
     completionHandler:(void (^)(Place *place, bool successed))completionHandler;

-(void)getDirections:(Place *)origin
        destinations:(NSArray<Place *> *)dests
   completionHandler:(void (^)(NSDictionary *polyLine, NSInteger distance, NSInteger duration, BOOL success))completionHandler;

-(void)getDirection:(Place *)dests
   completionHandler:(void (^)(NSDictionary *polyLine, NSInteger distance, NSInteger duration, BOOL success))completionHandler;

-(float)getDistance:(CLLocationCoordinate2D)coordinate;

-(void)startAccurateMonitor;
-(void)stopAccurateMonitor;

-(void)startSignificiantMonitor;
-(void)stopSignificiantMonitor;

-(BOOL)enableServices;
@end
