
#import "GMSMapView+VV.h"

@implementation GMSMapView (VV)

-(void)moveCameraToBounds:(CLLocationCoordinate2D)coord1 coord2:(CLLocationCoordinate2D)coord2
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:coord1 coordinate:coord2];
    UIEdgeInsets inset = UIEdgeInsetsMake(250, 30, 250, 30);
    GMSCameraPosition *newCamera = [self cameraForBounds:bounds insets:inset];
    self.camera = newCamera;
}

-(void)moveCameraToLocation:(CLLocationCoordinate2D)location
{
    GMSCameraPosition *newCamera = [GMSCameraPosition cameraWithTarget:location zoom:MAP_ZOOM];
    self.camera = newCamera;
}
@end
