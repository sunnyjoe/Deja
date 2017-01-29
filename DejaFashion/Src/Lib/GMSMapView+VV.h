
#import <GoogleMaps/GoogleMaps.h>

#define MAP_ZOOM 17

@interface GMSMapView (VV)

-(void)moveCameraToBounds:(CLLocationCoordinate2D)coord1 coord2:(CLLocationCoordinate2D)coord2;
-(void)moveCameraToLocation:(CLLocationCoordinate2D)location;
@end
