
@import <Foundation/CPObject.j>
@import "MKPlacemark.j"

@implementation MKGeocoder : CPObject
{
  CLLocationCoordinate2D coordinate @accessors(readonly);
  
  CPPlacemark placemark @accessors(readonly);

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
     	self.placemark = [[MKPlacemark alloc] initWithJSON:inResult[0]];       	
      
      	self.coordinate = self.placemark.coordinate;
      	
	    if([delegate respondsToSelector:@selector(geocoder:didFindLocation:)])
		{
			[delegate geocoder:self didFindLocation:self.coordinate];
		}

      }

  });
	
}



@end
