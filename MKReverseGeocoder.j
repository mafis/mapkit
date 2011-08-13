
@import <Foundation/CPObject.j>
@import "MKPlacemark.j"

@implementation MKReverseGeocoder : CPObject
{
  id delegate @accessors;
  CLLocationCoordinate2D coordinate @accessors;
  MKPlacemark placemark @accessors;
  bool quering @accessors;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init])
    {
        self.coordinate = aCoordinate;
    }
    return self;
}

-(void)cancel
{
	
}

-(void)start
{
	 var geocoder = new google.maps.Geocoder();
		
	 geocoder.geocode({'latLng': LatLngFromCLLocationCoordinate2D(coordinate)}, function(results, status) 
	 {
      if (status == google.maps.GeocoderStatus.OK)
      {
        if (results[0]) {
        	self.placemark = [[MKPlacemark alloc] initWithJSON:results[0]];       	
        	        	       	       
        	        	
        	if([delegate respondsToSelector:@selector(reverseGeocoder:didFindPlacemark:)])
			{
				[delegate reverseGeocoder:self didFindPlacemark:self.placemark];
			}

        /*
          map.setZoom(11);
          marker = new google.maps.Marker({
              position: latlng,
              map: map
          });
          infowindow.setContent();
          infowindow.open(map, marker); */
        }
      } 
      else 
      {
      	if([delegate respondsToSelector:@selector(reverseGeocoder:didFailWithError:)])
		{
			//TODO: Better Error Message
			[delegate reverseGeocoder:self didFailWithError:@"Error"];
		}
      
      }
    });


	
	
}




@end
