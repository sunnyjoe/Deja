

#import "Place.h"

@implementation Place

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.latitude = coordinate.latitude;
    self.longitude = coordinate.longitude;
}

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D  cc;
    cc.latitude = self.latitude;
    cc.longitude = self.longitude;
    return cc;
}


+(Place *) parsePlaceFromGMSPlace:(GMSPlace *)gmsPlace
{
    if (!gmsPlace)
    {
        return nil;
    }
    Place *result = [Place new];
    result.uniqueId = gmsPlace.placeID;
    result.name = gmsPlace.name;
    result.address = gmsPlace.formattedAddress;
    result.latitude = gmsPlace.coordinate.latitude;
    result.longitude = gmsPlace.coordinate.longitude;
    return result;
}




+(Place *) parsePlaceFromJson:(NSDictionary *)json
{
    if (!json)
    {
        return nil;
    }
    Place *result = [Place new];
    result.uniqueId = [json objectForKey:@"objectId"];
    result.name = [json objectForKey:@"name"];
    result.address = [json objectForKey:@"address"];
    result.latitude = ((NSNumber *)[json objectForKey:@"latitude"]).doubleValue;
    result.longitude = ((NSNumber *)[json objectForKey:@"longitude"]).doubleValue;
    return result;
    
}

-(NSDictionary *)toDict
{
    NSMutableDictionary *json = [NSMutableDictionary new];
    if (self.uniqueId)
    {
        [json setObject:self.uniqueId forKey:@"objectId"];
    }
    if (self.name)
    {
        [json setObject:self.name forKey:@"name"];
    }
    
    if (self.address)
    {
        [json setObject:self.address forKey:@"address"];
    }
    if (self.latitude)
    {
        [json setObject:@(self.latitude) forKey:@"latitude"];
    }
    if (self.longitude)
    {
        [json setObject:@(self.longitude) forKey:@"longitude"];
    }
    return json;
}


-(BOOL)isEquels:(Place *)place
{
    if (!place)
    {
        return NO;
    }
    if ([self.uniqueId isEqualToString:place.uniqueId]
        && [self.name isEqualToString:place.name]
        && [self.address isEqualToString:place.address]
        && self.latitude == place.latitude
        && self.longitude == place.longitude)
    {
        return true;
    }
    return false;
}

-(NSString *)description
{
    return [self toDict].description;
}


@end
