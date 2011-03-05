
@import <Foundation/CPObject.j>

@implementation MKGeocoder : CPObject
{
  id delegate @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (void)geocodeAddress:(CPString)anAddress doneSelector:(SEL)aSelector
{
  var geocoder = new google.maps.Geocoder();
  var value = null;

  geocoder.geocode({ address: anAddress}, function(inResult, inGeocoderStatus) {
      if (inGeocoderStatus != google.maps.GeocoderStatus.OK)
      return;

      if (inResult.length == 0)
      return;

      var resultLatLng = inResult && inResult[0] && inResult[0].geometry && inResult[0].geometry.location;
      if (!resultLatLng) return;
      value = CLLocationCoordinate2DFromLatLng(resultLatLng);
      objj_msgSend([self delegate], aSelector, value);
      });
  
}
@end
