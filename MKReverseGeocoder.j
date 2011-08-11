
@import <Foundation/CPObject.j>

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
	if([delegate respondsToSelector:@selector(reverseGeocoder:didFindPlacemark:)])
	{
		
	}
	
	if([delegate respondsToSelector:@selector(reverseGeocoder:didFailWithError:)])
	{
		
	}
}




@end
