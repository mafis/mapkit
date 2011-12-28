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
   
	var canvasProjectionOverlay;	
	
	//New
	
	BOOL zoomEnabled @accessors(readonly, getter=isZoomEnabled);
	
	BOOL scrollEnabled @accessors(readonly, getter=isScrollEnabled);
	
	MKMapRect visibleMapRect;
	
	
	//Annotations
	CPArray annotations @accessors(readonly);
    
	CGRect annotationVisibleRect @accessors(readonly);
	
	CPArray selectedAnnotations @accessors();
	
	CPArray _dequeueAnnotationViews;
	
	CPDictionary _annotationViews;
	
	CPPopover _annotationPopover;
	
	//Overlays TODO:Implement
	CPArray overlays @accessors(readonly);
	
	//DUMMY
	BOOL showsUserLocation @accessors();
	BOOL userLocationVisible @accessors(getter=isUserLocationVisible);
	var userLocation @accessors(readonly);
	
	CPView selectedAnnotationView;
	
	BOOL busy;
}
//Converting Map Coordinates
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(CPView)view
{
	  var point = CPPointMake(-100,-100);
	  
	  if(canvasProjectionOverlay)
	  {
		  point = canvasProjectionOverlay.getProjection().fromLatLngToContainerPixel(LatLngFromCLLocationCoordinate2D(coordinate));
	  }
	  
	  return point;
}

- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(CPView)view
{
	var location = CLLocationCoordinate2DMake(0.0,0.0);
	
	if(canvasProjectionOverlay)
	{
		location = canvasProjectionOverlay.getProjection().fromContainerPixelToLatLng(point);
	}
	  
	return location;
}

- (MKCoordinateRegion)convertRect:(CGRect)rect toRegionFromView:(CPView)view
{
	
}

- (CGRect)convertRegion:(MKCoordinateRegion)region toRectToView:(CPView)view
{
	
}

//Adjusting Map Regions and Rectangles
- (MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region
{
	
}

- (MKMapRect)mapRectThatFits:(MKMapRect)mapRect
{
	
	
}

- (MKMapRect)mapRectThatFits:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets
{
		
}

//Annotations

-(void)setSelectedAnnotations:(CPArray)aSelectedAnnotations
{
	
}

-(void)selectAnnotation:(MKAnnotation) animated:(BOOL)animated
{
	
}

-(void)deselectAnnotation:(MKAnnotation) animated:(BOOL)animated
{
	
}


- (MKAnnotationView)dequeueReusableAnnotationViewWithIdentifier:(CPString)identifier
{
	var annotationView = [_dequeueAnnotationViews lastObject];
	[_dequeueAnnotationViews removeLastObject];
	
	return annotationView;
}

- (MKAnnotationView)viewForAnnotation:(MKAnnotation)annotation
{
	var annotationView = null;
	
	if([delegate respondsToSelector:@selector(mapView:viewForAnnotation:)])
	{
		annotationView = [delegate mapView:self viewForAnnotation:annotation];
	}
	
	return annotationView;
	
}

-(CPSet)annotationsInMapRect:(MKMapRect)mapRect
{
	
}


var map_bounds;

-(void)_refreshAnnotations
{
	map_bounds = [self namespace].getBounds();
/*	 var i = 0, limit = [annotations count], busy = false; 
	 var processor = setInterval(function() 
	 { 
	    if(!busy)
	    { 
	      busy = true; 
	      var annotation = annotations[i];
		  [self _refreshAnnotation:annotation];
			
	      if(++i == limit)
	      { 
	        clearInterval(processor); 
	      } 
	      busy = false;
	    } 
	 }, 1);*/
	var count = [annotations count];
	
	for (var i=0; i < count; i++) {
		[self _refreshAnnotation:annotations[i]];

	};
	
	map_bounds = null;	
}


-(void)_refreshAnnotation:(MKAnnotation)aAnnotation
{
	if(map_bounds.contains(LatLngFromCLLocationCoordinate2D([aAnnotation coordinate])))
	{
		var point = [self convertCoordinate:[aAnnotation coordinate] toPointToView:self];
		
		if(![_annotationViews containsKey:[aAnnotation UID]])
		{
			var annotationView = [self viewForAnnotation:aAnnotation];
			[annotationView setFrameOrigin:CGPointMake(point.x,point.y - 10)];
			[annotationView setAnnotation:aAnnotation];
			[annotationView setDelegate:self];
			[_annotationViews setValue:annotationView forKey:[aAnnotation UID]];
			[self addSubview:annotationView];
		}
		else
		{
			var annotationView = [_annotationViews valueForKey:[aAnnotation UID]];
			[annotationView setFrameOrigin:CGPointMake(point.x,point.y - 10)];
		}
		
	}
	else
	{
		[self _removeAnnotationViewForAnnotation:aAnnotation];
	}
}

-(void)_removeAnnotationViewForAnnotation:(MKAnnotation)aAnnotation
{
	if([_annotationViews containsKey:[aAnnotation UID]])
	{	
		var annotationView = [_annotationViews valueForKey:[aAnnotation UID]];
		[annotationView removeFromSuperview];
		
		//Set AnnotaionView Annotation to Nil for reuse
		[annotationView setAnnotation:nil];
		[annotationView setDelegate:nil];
		
		[_dequeueAnnotationViews addObject:annotationView];
		[_annotationViews removeObjectForKey:[aAnnotation UID]];
		
		if(annotationView === selectedAnnotationView)
		{
			[_annotationPopover close];
		}
	}
}


//AnnotationViewDelegate
-(void)annotationViewdidSelected:(MKAnnotationView)aAnnotationView
{
	CPLog.debug("annotationViewdidSelected:");

	selectedAnnotationView = aAnnotationView;

	if(_annotationPopover)
	{
		[_annotationPopover close];
	}
		var g = CPMinYEdge;

   		var a = CPPopoverAppearanceHUD;
   	 
   	  	_annotationPopover = [[CPPopover alloc] init];
        var viewC = [[CPViewController alloc] init];
        var  view = [[CPView alloc] initWithFrame:CPRectMake(0.0, 0.0, 200, 50)];
		
		var label = [[CPTextField alloc] initWithFrame:CPRectMake(0.0,0.0, 200,25)];
		[label setStringValue:[[aAnnotationView annotation] title]]; 
		[label setTextColor:[CPColor whiteColor]];
				
		[view addSubview:label];
		
   		[viewC setView:view];
    	[_annotationPopover setContentViewController:viewC];
  	  	[_annotationPopover setAppearance:a];
  		[_annotationPopover setDelegate:self];
   		[_annotationPopover showRelativeToRect:nil ofView:selectedAnnotationView preferredEdge:g];

   

	if([delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)])
	{
		[delegate mapView:self didSelectAnnotationView:selectedAnnotationView];
	}
}


//Manipulating the Visible Portion of the Map
-(void)setMKMapRect:(MKMapRect)aVisibleMapRect
{
	
}

-(void)setMKMapRect:(MKMapRect)aVisibleMapRect animated:(BOOL)animated
{
	
}


-(void)setMKMapRect:(MKMapRect)aVisibleMapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animate
{
	
}

-(MKMapRect)MKMapRect
{
	return visibleMapRect;
}


-(void)_setMKMapRect
{
	var map_bounds = [self namespace].getBounds();

	var x = map_bounds.getSouthWest().lat();
  	var y = map_bounds.getSouthWest().lng();
  	var width = map_bounds.getNorthEast().lat() - x;
  	var height = map_bounds.getNorthEast().lng() - y;	
  	
  	visibleMapRect = MKMapRectMake(x,y,width,height);
  		
}

-(void)setZoomEnabled:(BOOL)enabled
{
	
}

-(void)setScrollEnabled:(BOOL)enabled
{
	
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
        _annotationViews = [[CPDictionary alloc] init];
        _dequeueAnnotationViews = [CPArray array];
      
       
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
 
  new google.maps.event.addListener([self namespace], 'click', function(event) { 
	if(_annotationPopover)
	{
		[_annotationPopover close];
	}
	
	 if([delegate respondsToSelector:@selector(mapView:didClickedAtLocation:)])
	 {
		 [delegate mapView:self didClickedAtLocation:CLLocationCoordinate2DFromLatLng(event.latLng)];
	 }
  });
  
  
  new google.maps.event.addListener([self namespace], 'center_changed', function(event){
	if(!busy)
	{
		busy = true;
	  	[self setValue:CLLocationCoordinate2DFromLatLng([self namespace].getCenter()) forKey:@"centerCoordinate"];
		[self _refreshAnnotations];  	
		busy = false;
	}
	
	});

  
 	//Throws the loadedMap Event after the Map is complete loaded
	google.maps.event.addListenerOnce([self namespace], 'idle', function(){
		if([delegate respondsToSelector:@selector(loadedMap:)])
		{
		   	[delegate loadedMap:self];
		}
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

- (void)setRegion:(MKCoordinateRegion)aRegion animated:(BOOL)animated
{

}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)aCoordinate
{
	
	if(aCoordinate === CPNoSelectionMarker || (aCoordinate.longitude == 0 && aCoordinate.latitude == 0))
		return;
	
    if (m_centerCoordinate &&
        CLLocationCoordinate2DEqualToCLLocationCoordinate2D(m_centerCoordinate, aCoordinate))
        return;
    	
    m_centerCoordinate = new CLLocationCoordinate2D(aCoordinate);


    if ([self namespace])
       [self namespace].panTo(LatLngFromCLLocationCoordinate2D(m_centerCoordinate));
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)aCoordinate animated:(BOOL)animated
{
	
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
		[annotations addObject:annotation];
	};
	
	[self _refreshAnnotations];
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
			[self _removeAnnotationViewForAnnotation:aAnnotation];

			
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
