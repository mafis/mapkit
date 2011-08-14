@implementation MKAnnotation : CPObject
{
	CPString title @accessors();
	CPString subtitle @accessors();
	CLLocationCoordinate2D coordinate @accessors(readonly);	
	
	CPString icon @accessors();
	
	var _marker;

}



- (id)init
{
	if(self = [super init])
	{
		_marker = new google.maps.Marker();   
		coordinate = CLLocationCoordinate2DMake(0.0,0.0);
		title = @"";
	}
	return self;
}

-(void)setIcon:(CPString)iconPath
{
	_marker.setIcon(null);	
	_marker.setIcon(iconPath);
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