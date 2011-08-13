@implementation MKAnnotation : CPObject
{
	CPString title @accessors();
	CPString subtitle @accessors();
	CLLocationCoordinate2D coordinate @accessors(readonly);	
	
	var _marker;

}



- (id)init
{
	if(self = [super init])
	{
		_marker = new google.maps.Marker();   
	}
	return self;
}

-(void)setCoordinate:(CLLocationCoordinate2D)aCoordinate
{
	coordinate = aCoordinate;
}

-(id)_marker
{
	_marker.position = LatLngFromCLLocationCoordinate2D(coordinate);
	_marker.title = title;
	
	return _marker;
}





@end