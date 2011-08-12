
@import <Foundation/CPObject.j>

@implementation MKGeocoder : CPObject
{
  CPString address @accessors(readonly);
  CLLocationCoordinate2D coordinate @accessors(readonly);

  id delegate @accessors;
 
}

- (id)initWithAdress:(CPString)anAddress
{
    if (self = [super init])
    {
        self.address = anAddress;
    }
    return self;
}

-(void)cancel
{
	
}

-(void)start
{
  var geocoder = new google.maps.Geocoder();

  geocoder.geocode({ address: address}, function(inResult, inGeocoderStatus) {
      if (inGeocoderStatus != google.maps.GeocoderStatus.OK || inResult.length == 0)
      {
	      if([delegate respondsToSelector:@selector(geocoder:didFailWithError:)])
		  {
		  	//TODO : Better Error Message
				[delegate geocoder:self didFailWithError:@"Geocoding error"];
		  }

      }
      else
      {
        var resultLatLng = inResult && inResult[0] && inResult[0].geometry && inResult[0].geometry.location;

		self.coordinate = CLLocationCoordinate2DFromLatLng(resultLatLng);

      	
	    if([delegate respondsToSelector:@selector(geocoder:didFindLocation:)])
		{
			[delegate geocoder:self didFindLocation:self.coordinate];
		}

      }

  });
	
}



@end
