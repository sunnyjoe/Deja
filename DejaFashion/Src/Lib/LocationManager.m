
#import "LocationManager.h"
#import "DJUrl.h"
#import "AFNetworking.h"
#import "DejaFashion-Swift.h"

@interface LocationManager()<CLLocationManagerDelegate>

@end


static LocationManager *instance;

@implementation LocationManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init
{
    NSAssert(!instance, @"This should be a singleton class.");
    self = [super init];
    return self;
}

-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
    }
    return _locationManager;
}

-(BOOL)enableServices
{
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)startAccurateMonitor
{
    if([CLLocationManager locationServicesEnabled])
    {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
       // self.locationManager.distanceFilter = 30; //every 30 meters get delegate callback
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] > 9) {
            self.locationManager.allowsBackgroundLocationUpdates = true;
        }
    }
}


-(void)startSignificiantMonitor
{
    if([CLLocationManager locationServicesEnabled])
    {
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

-(void)stopSignificiantMonitor
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}


-(void)stopAccurateMonitor
{
    [self.locationManager stopUpdatingLocation];
}

-(void)getDirection:(Place *)dests completionHandler:(void (^)(NSDictionary *, NSInteger, NSInteger, BOOL))completionHandler{
    Place *currentPlace = [[Place alloc] init];
    currentPlace.latitude = self.currentLocation.coordinate.latitude;
    currentPlace.longitude = self.currentLocation.coordinate.longitude;
    [self getDirections:currentPlace destinations:[NSArray arrayWithObject:dests] completionHandler:completionHandler];
}

-(NSString *)getLocationPair:(CLLocationCoordinate2D)coordinate{
    return [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
}

-(NSString *)getLocationOrIdFromPlace:(Place *)place{
    NSMutableString *locs = [NSMutableString new];
    if (place.uniqueId) {
        [locs appendString:@"place_id:"];
        [locs appendString:place.uniqueId];
    }else{
        [locs appendString:[self getLocationPair:place.coordinate]];
    }
    return locs;
}

-(void)getDirections:(Place *)origin
        destinations:(NSArray<Place *> *)dests
   completionHandler:(void (^)(NSDictionary *polyLine, NSInteger distance, NSInteger duration, BOOL success))completionHandler

{
    
    if (!origin || !dests || !dests.count) {
        completionHandler(nil, 0, 0, NO);
        return;
    }
    if (dests.count == 0) {
        return;
    }
    
    NSMutableString *directionsURLString = [NSMutableString stringWithString:@"https://maps.googleapis.com/maps/api/directions/json?origin="];
    [directionsURLString appendString:[self getLocationOrIdFromPlace:origin]];
    
    if (dests.count > 1) {
        NSMutableString *waypoints = [NSMutableString new];
        [waypoints appendString: @"&waypoints="];
        [waypoints appendString:[self getLocationOrIdFromPlace:dests[0]]];
        
        if (dests.count > 2) {
            [waypoints appendString: @"|"];
            [waypoints appendString:[self getLocationOrIdFromPlace:dests[1]]];
        }
        [directionsURLString appendString:waypoints];
    }
    
    [directionsURLString appendString: @"&destination="];
    [directionsURLString appendString:[self getLocationOrIdFromPlace:dests.lastObject]];
    
    [directionsURLString appendString: @"&mode=driving"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[directionsURLString urlEncode]]];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler([NSDictionary new], 0, 0, NO);
        }
        else
        {
            NSDictionary *dictionary = (NSDictionary *)responseObject;
            NSString *status = [dictionary objectForKey:@"status"];
            if ([status isEqualToString: @"OK"])
            {
                NSDictionary *selectedRoute = [((NSArray *)[dictionary objectForKey:@"routes"]) objectAtIndex:0];
                NSDictionary *overviewPolyline = [selectedRoute objectForKey: @"overview_polyline"];
                NSArray *legs = [selectedRoute objectForKey: @"legs"];
                int totalDistanceInMeters = 0;
                int totalDurationInSeconds = 0;
                
                for (NSDictionary *leg in legs) {
                    NSDictionary *distance = [leg objectForKey:@"distance"];
                    int value = ((NSNumber *)[distance objectForKey:@"value"]).intValue;
                    totalDistanceInMeters += value;
                    
                    
                    NSDictionary *duration = [leg objectForKey:@"duration"];
                    value = ((NSNumber *)[duration objectForKey:@"value"]).intValue;
                    totalDurationInSeconds += value;
                }
                completionHandler(overviewPolyline, totalDistanceInMeters, totalDurationInSeconds, YES);
            }
            else
            {
                completionHandler([NSDictionary new], 0, 0, NO);
            }
        }
    }];
    [dataTask resume];
    
}

-(void) geocodeAddress:(CLLocationCoordinate2D)location
     completionHandler:(void (^)(Place *place, bool successed))completionHandler
{
    NSMutableString *urlString = [NSMutableString stringWithString:@"https://maps.googleapis.com/maps/api/geocode/json?latlng="];
    [urlString appendString:[NSString stringWithFormat:@"%f", location.latitude]];
    [urlString appendString:@","];
    [urlString appendString:[NSString stringWithFormat:@"%f", location.longitude]];
    //  [urlString appendString:@"&key="];
    //  [urlString appendString:kDJGoogleMapInfoServiceKey];
    NSURL *geocodeURL = [NSURL URLWithString:[urlString urlEncode]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *geocodingResultsData = [[NSData alloc] initWithContentsOfURL:geocodeURL];
        if (!geocodingResultsData) {
            return;
        }
        NSError *error;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:geocodingResultsData options:NSJSONReadingMutableContainers error:&error];
        NSString *status = [dictionary objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            NSArray *allResults = [dictionary objectForKey:@"results"];
            NSDictionary *result = [allResults objectAtIndex:0];
            NSString *address = [result objectForKey:@"formatted_address"];
            // Keep the most important values.
            Place *place = [Place new];
            place.uniqueId = [result objectForKey:@"place_id"];
            place.name = address;
            place.address = address;
            [place setCoordinate: location];
            completionHandler(place, YES);
            //
        }
        else
        {
            completionHandler(nil, NO);
            
        }
    });
}

-(float)getDistance:(CLLocationCoordinate2D)coordinate{
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    return [userLocation distanceFromLocation:_currentLocation] / 1000; //km
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.lastObject)
    {
        //        if (!self.currentLocation)
        //        {
        //            self.currentLocation = locations.lastObject;
        //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCATION_INITIATE object:nil];
        //        }
        //        else
        //        {
        NSLog(@"didUpdateLocations");
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        }
        self.currentLocation = locations.lastObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCATION_UPDATE object:nil];
        //        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;
{
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCATION_AUTH_ALLOW object:nil];
        [[DJStatisticsLogic instance] addTraceLog:[DJStatisticsKeys system_click_allow_location]];
        
        [self startSignificiantMonitor];
    }
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCATION_AUTH_DENIED object:nil];
    }
    
}


@end
