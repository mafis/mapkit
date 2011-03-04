@import <Foundation/CPObject.j>
@implementation MKMarker : CPObject
{
  google.maps.Marker gmarker @accessors;
  google.maps.InfoWindow infoWindow;
  MKMapView mapView;
}

- (id)init
{
    if (self = [super init])
    {
      gmarker = new google.maps.Marker();
    }
    return self;
}
 

- (CLLocationCoordinate2D)position
{
  CLLocationCoordinate2DFromLatLng(gmarker.getPosition());
}

- (void)setPosition:(CLLocationCoordinate2D)aCoordinate
{
  gmarker.setPosition(LatLngFromCLLocationCoordinate2D(aCoordinate));
}

- (void)addToMapView:(MKMapView)aMapView
{
  [aMapView addMarker:self];
}

- (CPString)title
{
  gmarker.getTitle();
}

- (void)setTitle:(CPString)aTitle
{
  gmarker.setTitle(aTitle);
}

-(CPString)infoWindowContent
{
  if(infoWindow) return infoWindow.getContent();
  return @"";
}

-(void)setInfoWindowContent:(CPString)aString
{
  if(!infoWindow) { 
    infoWindow = new google.maps.InfoWindow();
    infoWindow.open(gmarker.getMap(), gmarker);
  }
  infoWindow.setContent(aString);
}
@end
