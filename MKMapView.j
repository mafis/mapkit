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

function CanvasProjectionOverlay() {}
CanvasProjectionOverlay.prototype = new google.maps.OverlayView();
CanvasProjectionOverlay.prototype.constructor = CanvasProjectionOverlay;
CanvasProjectionOverlay.prototype.onAdd = function(){};
CanvasProjectionOverlay.prototype.draw = function(){};
CanvasProjectionOverlay.prototype.onRemove = function(){};


@import <AppKit/CPView.j>

@import "MKGeometry.j"
@import "MKTypes.j"


@implementation MKMapView : CPView
{
    CLLocationCoordinate2D  m_centerCoordinate;
    int                     m_zoomLevel;
    MKMapType               m_maptype;

    BOOL                    m_scrollWheelZoomEnabled;

    // Tracking
    BOOL                    m_previousTrackingLocation;

    // Google Maps v3 DOM Support
   	DOMElement              m_DOMMapElement;
	Object                  m_map;

    @outlet id delegate @accessors;
    
    CPArray annotations @accessors(readonly);
    
    CPArray annotationViews;
    
    
    CPDictionary markerDictionary;

	var canvasProjectionOverlay;


}


+ (void)initialize
{
	[self exposeBinding:CPValueBinding];
}
 
+ (Class)_binderClassForBinding:(CPString)theBinding
{
    if (theBinding === CPValueBinding)
        return [_CPValueBinder class];
	
    return [super _binderClassForBinding:theBinding];
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
        
        annotations = [CPArray array];
        annotationViews = [CPArray array];
        
        markerDictionary = [[CPDictionary alloc] init];

        [self _buildDOM];
    }

    return self;
}


- (void)_buildDOM
{

  m_DOMMapElement = document.createElement('div');
  m_DOMMapElement.setAttribute('id',"map_view_canvas_"+[self UID],0);
  with (m_DOMMapElement.style) {
    position = "absolute";
    left = "0px";
    top = "0px";
    width = "100%";
    height = "100%";
  }
  _DOMElement.appendChild(m_DOMMapElement);
  
  var myLatlng = LatLngFromCLLocationCoordinate2D([self centerCoordinate]);
  optiones = {
    zoom: [self zoomLevel],
    center: myLatlng,
    mapTypeId: [[self class] _mapTypeObjectForMapType:[self mapType]],
    scrollwheel: [self scrollWheelZoomEnabled],
    disableDefaultUI: true,
  }
  m_map = new google.maps.Map(m_DOMMapElement, optiones);
  canvasProjectionOverlay = new CanvasProjectionOverlay();
  canvasProjectionOverlay.setMap(m_map);
  
   if([delegate respondsToSelector:@selector(loadedMap:)])
  {
   	[delegate loadedMap:self];
  }
  
  new google.maps.event.addListener([self namespace], 'click', function(event) { 
  	if([delegate respondsToSelector:@selector(mapView:didClickedAtLocation:)])
	 {
		 [delegate mapView:self didClickedAtLocation:CLLocationCoordinate2DFromLatLng(event.latLng)];
	 }
	 
	
  });
  
  
  
  new google.maps.event.addListener([self namespace], 'center_changed', function(event){
	  [self setValue:CLLocationCoordinate2DFromLatLng([self namespace].getCenter()) forKey:@"centerCoordinate"];
  	/*
  	  for (var i=0; i < [annotationViews count]; i++) {
  	  	 var annotationView = annotationViews[i];
	  	 var point = canvasProjectionOverlay.getProjection().fromLatLngToContainerPixel(LatLngFromCLLocationCoordinate2D(annotationView.annotation.coordinate));
		
		var animation = [[LPViewAnimation alloc] initWithViewAnimations:[
        {
            @"target": annotationView,
            @"animations": [
                [LPOriginAnimationKey, [annotationView frameOrigin], CGPointMake(point.x,point.y)]
            ]
        }
    ]];

  	  	 
  	  	 [annotationView setFrame:CGRectMake(point.x,point.y,100,100)];
  		
  		//console.log(canvasProjectionOverlay.getProjection().fromLatLngToContainerPixel([self namespace].getCenter()));*/
  });
  
}

- (Object) namespace {
  
  return m_map;
  
}

- (MKCoordinateRegion)region
{
    if ([self namespace])
        return MKCoordinateRegionFromLatLngBounds([self namespace].getBounds());

    return nil;
}

- (void)setRegion:(MKCoordinateRegion)aRegion
{
    m_region = aRegion;

    if ([self namespace])
    {
        [self setZoomLevel:[self namespace].getBoundsZoomLevel(LatLngBoundsFromMKCoordinateRegion(aRegion))];
        [self setCenterCoordinate:aRegion.center];
    }
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)aCoordinate
{
	
	if(aCoordinate === CPNoSelectionMarker || (aCoordinate.longitude == 0 && aCoordinate.latitude == 0))
		return;
	
    if (m_centerCoordinate &&
        CLLocationCoordinate2DEqualToCLLocationCoordinate2D(m_centerCoordinate, aCoordinate))
        return;
    

    	
    m_centerCoordinate = new CLLocationCoordinate2D(aCoordinate);
   // [self _reverseSetBinding];
    //L

    if ([self namespace])
       [self namespace].panTo(LatLngFromCLLocationCoordinate2D(m_centerCoordinate));

}

-(void)setObjectValue:(id)aValue
{
	[self setCenterCoordinate:aValue];
}

- (void)_reverseSetBinding
{
    var binderClass = [[self class] _binderClassForBinding:CPValueBinding],
        theBinding = [binderClass getBinding:CPValueBinding forObject:self];

    [theBinding reverseSetValueFor:CPValueBinding];
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

    if ([self namespace])
        [self namespace].panTo(LatLngFromCLLocationCoordinate2D(aCoordinate));
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

    if ([self namespace])
        [self namespace].setZoom(aZoomLevel);
}

- (int)zoomLevel
{
    return m_zoomLevel;
}

- (void)setMapType:(MKMapType)aMapType
{
    m_maptype = aMapType;

    if (m_maptype)
        m_maptype.setMapType([[self class] _mapTypeObjectForMapType:m_maptype]);
}

- (MKMapType)mapType
{
    return m_maptype;
}

- (void)setScrollWheelZoomEnabled:(BOOL)shouldBeEnabled
{
    m_scrollWheelZoomEnabled = shouldBeEnabled;

    if ([self namespace])
        [self namespace].setOptions({scrollwheel: m_scrollWheelZoomEnabled});
}

- (BOOL)scrollWheelZoomEnabled
{
    return m_scrollWheelZoomEnabled;
}

- (void)addAnnotation:(MKAnnotation)annotation
{
	
	[self addAnnotations:[CPArray arrayWithObject:annotation]];
}

- (void)addAnnotations:(CPArray)aAnnotationArray
{
	var annotationsCount = [aAnnotationArray count];
	
	for (var i =0; i < annotationsCount; i++) {
		var annotation = aAnnotationArray[i];
			
		var marker = null;
	
		
		var point = canvasProjectionOverlay.getProjection().fromLatLngToContainerPixel(LatLngFromCLLocationCoordinate2D(annotation.coordinate));
		var view = [[MKAnnotationView alloc] initWithFrame:CGRectMake(point.x,point.y - 100,100,100)];
		[view setAnnotation:annotation];
		[view setBackgroundColor:[CPColor blackColor]];
		[self addSubview:view];
		
		[annotationViews addObject:view];
		
	console.log(point);
		if([markerDictionary valueForKey:[annotation UID]])
		{
			marker = [markerDictionary valueForKey:[annotation UID]];
			marker.setMap([self namespace]);
		}
		else
		{
			
			var marker = new google.maps.Marker({
    			position: LatLngFromCLLocationCoordinate2D([annotation coordinate]),
    			map: [self namespace]
	  		});
  			[markerDictionary setValue:marker forKey:[annotation UID]];

			
		}
		
		[annotations addObject:annotation];
	};

}

- (void)removeAnnotation:(MKAnnotation)annotation
{
	
	[self removeAnnotation:[CPArray arrayWithObject:annotation]];
}

- (void)removeAnnotations:(CPArray)aAnnotationArray
{
	var annotationsCount = [aAnnotationArray count];
	
	for (var i =0; i < annotationsCount; i++) {
		var annotation = aAnnotationArray[i]
		
		if(annotation)
		{
			var marker = [markerDictionary valueForKey:[annotation UID]];

			if(marker)
	  		{
				marker.setMap(null);
				[markerDictionary setValue:null forKey:[annotation UID]];	
	  		}		
			
			[annotations removeObject:annotation];
		}
	};
	
	
}

-(void)layoutSubviews
{
	google.maps.event.trigger([self namespace], 'resize');
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
