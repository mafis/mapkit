
@import <Foundation/CPObject.j>
@import "MKMapView.j"


MKLocationStringRegEx = /\s*<(\-?\d*\.?\d*),\s*(\-?\d*\.?\d*)>\s*$/;

@implementation MKLocation : CPObject
{
    float         _latitude   @accessors(property=latitude, readonly);
    float         _longitude  @accessors(property=longitude, readonly);
}

+ (MKLocation)location
{
    return [[MKLocation alloc] init];
}

+ (MKLocation)locationWithLatitude:(float)aLatitude longitude:(float)aLongitude
{
    return [[MKLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
}

//create a location from a String like this:
//san jose <37.3393857, -121.8949555>
+ (MKLocation)locationFromString:(CPString)aString
{
    var result = MKLocationStringRegEx.exec(aString);

    if (result && result.length === 3)
        return [MKLocation locationWithLatitude:result[1] longitude:result[2]];

    return nil;
}

- (id)initWithLatLng:(LatLng)aLatLng
{
    return [self initWithLatitude:aLatLng.lat() longitude:aLatLng.lng()];
}

- (id)initWithLatitude:(float)aLatitude longitude:(float)aLongitude
{
    self = [super init];

    if (self)
    {
        _latitude = aLatitude;
        _longitude = aLongitude;
    }

    return self;
}

- (LatLng)googleLatLng
{
    return new google.maps.LatLng(_latitude, _longitude);
}

@end

var MKLocationLatitudeKey   = @"MKLocationLatitudeKey",
    MKLocationLongitudeKey  = @"MKLocationLongitudeKey";

@implementation MKLocation (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super init];

    if (self)
    {
        _latitude = [aCoder decodeFloatForKey:MKLocationLatitudeKey];
        _longitude = [aCoder decodeFloatForKey:MKLocationLongitudeKey];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [aCoder encodeFloat:_latitude forKey:MKLocationLatitudeKey];
    [aCoder encodeFloat:_longitude forKey:MKLocationLongitudeKey];
}

@end
