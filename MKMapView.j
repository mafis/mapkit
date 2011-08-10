// MKMapView.j
// MapKit
//
// Created by Francisco Tolmasky.
// Copyright (c) 2010 280 North, Inc.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

@import <AppKit/CPView.j>

@import "MKGeometry.j"
@import "MKTypes.j"


@implementation MKMapView : CPView
{
    CLLocationCoordinate2D  m_centerCoordinate;
    int                     m_zoomLevel;
    MKMapType               m_mapType;

    BOOL                    m_scrollWheelZoomEnabled;

    // Tracking
    BOOL                    m_previousTrackingLocation;

    // Google Maps v2 DOM Support
    DOMElement              m_DOMMapElement;
    DOMElement              m_DOMGuardElement;
    Object                  m_map;

    @outlet id delegate @accessors;

}

+ (CPSet)keyPathsForValuesAffectingCenterCoordinateLatitude
{
    return [CPSet setWithObjects:@"centerCoordinate"];
}

+ (CPSet)keyPathsForValuesAffectingCenterCoordinateLongitude
{
    return [CPSet setWithObjects:@"centerCoordinate"];
}

+ (int)_mapTypeObjectForMapType:(MKMapType)aMapType
{
    return  [
                google.maps.MapTypeId.ROADMAP,
                google.maps.MapTypeId.HYBRID,
                google.maps.MapTypeId.SATELLITE,
                google.maps.MapTypeId.TERRAIN
            ][aMapType];
}

- (id)initWithFrame:(CGRect)aFrame
{
    return [self initWithFrame:aFrame centerCoordinate:nil];
}

- (id)initWithFrame:(CGRect)aFrame centerCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        [self setBackgroundColor:[CPColor colorWithRed:229.0 / 255.0 green:227.0 / 255.0 blue:223.0 / 255.0 alpha:1.0]];
        [self setCenterCoordinate:aCoordinate || new CLLocationCoordinate2D(52, -1)];
        [self setZoomLevel:6];
        [self setMapType:MKMapTypeStandard];
        [self setScrollWheelZoomEnabled:YES];

        [self _buildDOM];
    }

    return self;
}

- (void)_buildDOM
{
  m_DOMMapElement = document.createElement('div');
  with (m_DOMMapElement.style) {
    position = "absolute";
    left = "0px";
    top = "0px";
    width = "100%";
    height = "100%";
  }
  _DOMElement.appendChild(m_DOMMapElement);
  //if(typeof(google)=="undefined"){
    var url = 'http://maps.google.com/maps/api/js?sensor=true';
    var request = [CPURLRequest requestWithURL:url];
    var conn = [CPJSONPConnection sendRequest:request callback:"callback" delegate:self];
  //} else [self _buildMap];
}

-(void)connectionDidFinishLoading:(CPURLConnection)connection
{
  [self _buildMap];
}

-(void)_buildMap
{
  var myLatlng = LatLngFromCLLocationCoordinate2D([self centerCoordinate]);
  var myOptions = {
    zoom: [self zoomLevel],
    center: myLatlng,
    mapTypeId: [[self class] _mapTypeObjectForMapType:[self mapType]],
    scrollwheel: [self scrollWheelZoomEnabled]
  }
  m_map = new google.maps.Map(m_DOMMapElement, myOptions);
  if(delegate){
  
  	 if([delegate respondsToSelector:@selector(loadedMap:)])
	 {
    	[delegate loadedMap:self];
     }
  }
  
  new google.maps.event.addListener(m_map, 'click', function(event) { 
  	if([delegate respondsToSelector:@selector(mapView:didClickedAtLocation:)])
	 {
		 [delegate mapView:self didClickedAtLocation:CLLocationCoordinate2DFromLatLng(event.latLng)];
	 }
  });
  
}

- (Object) namespace {
  
  console.log("m_map", m_map);
  return m_map;
  
}

- (MKCoordinateRegion)region
{
    if (m_map)
        return MKCoordinateRegionFromLatLngBounds(m_map.getBounds());

    return nil;
}

- (void)setRegion:(MKCoordinateRegion)aRegion
{
    m_region = aRegion;

    if (m_map)
    {
        [self setZoomLevel:m_map.getBoundsZoomLevel(LatLngBoundsFromMKCoordinateRegion(aRegion))];
        [self setCenterCoordinate:aRegion.center];
    }
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (m_centerCoordinate &&
        CLLocationCoordinate2DEqualToCLLocationCoordinate2D(m_centerCoordinate, aCoordinate))
        return;

    m_centerCoordinate = new CLLocationCoordinate2D(aCoordinate);

    if (m_map)
        m_map.panTo(LatLngFromCLLocationCoordinate2D(m_centerCoordinate));
}

- (CLLocationCoordinate2D)centerCoordinate
{
    return new CLLocationCoordinate2D(m_centerCoordinate);
}

- (void)panToCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (m_centerCoordinate &&
        CLLocationCoordinate2DEqualToCLLocationCoordinate2D(m_centerCoordinate, aCoordinate))
        return;

    m_centerCoordinate = new CLLocationCoordinate2D(aCoordinate);

    if (m_map)
        m_map.panTo(LatLngFromCLLocationCoordinate2D(aCoordinate));
}

- (void)setCenterCoordinateLatitude:(float)aLatitude
{
    [self setCenterCoordinate:new CLLocationCoordinate2D(aLatitude, [self centerCoordinateLongitude])];
}

- (float)centerCoordinateLatitude
{
    return [self centerCoordinate].latitude;
}

- (void)setCenterCoordinateLongitude:(float)aLongitude
{
    [self setCenterCoordinate:new CLLocationCoordinate2D([self centerCoordinateLatitude], aLongitude)];
}

- (float)centerCoordinateLongitude
{
    return [self centerCoordinate].longitude;
}

- (void)setZoomLevel:(float)aZoomLevel
{
    m_zoomLevel = +aZoomLevel || 0;

    if (m_map)
        m_map.setZoom(aZoomLevel);
}

- (int)zoomLevel
{
    return m_zoomLevel;
}

- (void)setMapType:(MKMapType)aMapType
{
    m_mapType = aMapType;

    if (m_map)
        m_map.setMapType([[self class] _mapTypeObjectForMapType:m_mapType]);
}

- (MKMapType)mapType
{
    return m_mapType;
}

- (void)setScrollWheelZoomEnabled:(BOOL)shouldBeEnabled
{
    m_scrollWheelZoomEnabled = shouldBeEnabled;

    if (m_map)
        m_map.setOptions({scrollwheel: m_scrollWheelZoomEnabled});
}

- (BOOL)scrollWheelZoomEnabled
{
    return m_scrollWheelZoomEnabled;
}

- (void)addMarkerWithTitle:(CPString)aTitle atCoordinate:(CLLocationCoordinate2D)aCoordinate
{

  var marker = new google.maps.Marker({
      position: LatLngFromCLLocationCoordinate2D(aCoordinate), 
      map: m_map, 
      title:aTitle
  });   
}
- (void)layoutSubviews
{
	if (!m_map) return;
  google.maps.event.addListenerOnce(m_map, 'resize', function(coordinate){m_map.panTo(coordinate);}) //keep the center centered
	google.maps.event.trigger(m_map, 'resize', LatLngFromCLLocationCoordinate2D([self centerCoordinate]));
  
}

- (void)addMarker:(MKMarker)aMarker
{
  gmarker = [aMarker gmarker];
  if(m_map)gmarker.setMap(m_map);
}
@end

var MKMapViewCenterCoordinateKey    = @"MKMapViewCenterCoordinateKey",
    MKMapViewZoomLevelKey           = @"MKMapViewZoomLevelKey",
    MKMapViewMapTypeKey             = @"MKMapViewMapTypeKey";

@implementation MKMapView (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        [self setCenterCoordinate:CLLocationCoordinate2DFromString([aCoder decodeObjectForKey:MKMapViewCenterCoordinateKey])];
        [self setZoomLevel:[aCoder decodeObjectForKey:MKMapViewZoomLevelKey]];
        [self setMapType:[aCoder decodeObjectForKey:MKMapViewMapTypeKey]];
        [self setScrollWheelZoomEnabled:YES];

        [self _buildDOM];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:CPStringFromCLLocationCoordinate2D([self centerCoordinate]) forKey:MKMapViewCenterCoordinateKey];
    [aCoder encodeObject:[self zoomLevel] forKey:MKMapViewZoomLevelKey];
    [aCoder encodeObject:[self mapType] forKey:MKMapViewMapTypeKey];
}

@end
