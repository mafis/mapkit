
@import <AppKit/CPView.j>

@import "MKLocation.j"


var APIKey = @"ABQIAAAAhiSDpTbEtof5V-C_X90kxBQ9X6011y0sJ1RXT7gLKgEm76I9ChRoDebbydIfHUI3jZncPkN9YzRGHQ";

@implementation MKMapView : CPView
{
    DOMElement  m_DOMMapElement;
    Object      m_map;

    MKLocation  m_location;
    int         m_zoomLevel;
    BOOL        m_scrollWheelZoomEnabled;
}

+ (void)setAPIKey:(CPString)anAPIKey
{
    APIKey  = anAPIKey;
}

+ (CPSet)keyPathsForValuesAffectingLocationLatitude
{
    return [CPSet setWithObjects:@"location"];
}

+ (CPSet)keyPathsForValuesAffectingLocationLongitude
{
    return [CPSet setWithObjects:@"location"];
}

- (id)initWithFrame:(CGRect)aFrame
{
    return [self initWithFrame:aFrame location:nil];
}

- (id)initWithFrame:(CGRect)aFrame location:(MKLocation)aLocation
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        [self setLocation:aLocation || [MKLocation locationWithLatitude:52 longitude:-1]];
        [self setZoomLevel:6];
        [self setScrollWheelZoomEnabled:YES];

        [self _buildDOM];
    }

    return self;
}

- (void)_buildDOM
{
    performWhenGoogleMapsScriptLoaded(function()
    {
        m_DOMMapElement = document.createElement("div");
        m_DOMMapElement.id = "MKMapView" + [self UID];

        var style = m_DOMMapElement.style,
            bounds = [self bounds],
            width = CGRectGetWidth(bounds),
            height = CGRectGetHeight(bounds);

        style.overflow = "hidden";
        style.position = "absolute";
        style.visibility = "visible";
        style.zIndex = 0;
        style.left = -width + "px";
        style.top = -height + "px";
        style.width = width + "px";
        style.height = height + "px";

        // Google Maps can't figure out the size of the div if it's not in the DOM tree, 
        // so we have to temporarily place it somewhere on the screen to appropriately size it.
        document.body.appendChild(m_DOMMapElement);

        m_map = new google.maps.Map(m_DOMMapElement,
        {
            center:[m_location googleLatLng],
            zoom:m_zoomLevel,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
        });

        google.maps.event.trigger(m_map, "resize");

        style.left = "0px";
        style.top = "0px";

        // REMOVE this or you will get WRONG_DOCUMENT_ERRORS (4)!
        document.body.removeChild(m_DOMMapElement);

        _DOMElement.appendChild(m_DOMMapElement);
/*
        google.maps.Event.addListener(m_map, "zoomend", function(oldZoomLevel, newZoomLevel)
        {
            [self setZoomLevel:newZoomLevel];

//            [[CPRunLoop currentRunLoop] limitDataForMode:CPDefaultRunLoopMode];
        });
*/
    });
}

- (void)setFrameSize:(CGSize)aSize
{
    [super setFrameSize:aSize];

    var bounds = [self bounds];

    if (m_DOMMapElement)
    {
        var style = m_DOMMapElement.style;

        style.width = CGRectGetWidth(bounds) + "px";
        style.height = CGRectGetHeight(bounds) + "px";

        google.maps.event.trigger(m_map, "resize");
    }
}

- (void)setLocation:(MKLocation)aLocation
{
    m_location = aLocation;

    if (m_map)
        m_map.setCenter([m_location googleLatLng], 8);
}

- (MKLocation)location
{
    return m_location;
}

- (void)setLocationLatitude:(float)aLatitude
{
    [self setLocation:[MKLocation locationWithLatitude:aLatitude longitude:[self locationLongitude]]];
}

- (float)locationLatitude
{
    return [[self location] latitude];
}

- (void)setLocationLongitude:(float)aLongitude
{
    [self setLocation:[MKLocation locationWithLatitude:[self locationLatitude] longitude:aLongitude]];
}

- (float)locationLongitude
{
    return [[self location] longitude];
}

- (void)setZoomLevel:(float)aZoomLevel
{
    m_zoomLevel = +aZoomLevel || 0;

    if (m_map)
        m_map.setZoom(m_zoomLevel);
}

- (int)zoomLevel
{
    return m_zoomLevel;
}

- (void)setScrollWheelZoomEnabled:(BOOL)shouldBeEnabled
{
    m_scrollWheelZoomEnabled = shouldBeEnabled;

    if (m_map)
        m_map.setScrollWheelZoomEnabled(m_scrollWheelZoomEnabled);
}

- (BOOL)scrollWheelZoomEnabled
{
    return m_scrollWheelZoomEnabled;
}

- (void)takeStringAddressFrom:(id)aSender
{
    var geocoder = new google.maps.Geocoder();

    geocoder.geocode({ address:[aSender stringValue] }, function(results, aStatus)
    {
        if (aStatus !== google.maps.GeocoderStatus.OK)
            return;

        [self setLocation:[[MKLocation alloc] initWithLatLng:results[0].geometry.location]];
        [self setZoomLevel:7];
    });
}

- (void)mouseDown:(CPEvent)anEvent
{
    [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
    [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];
}

@end

var GoogleMapsScriptQueue   = [];

var performWhenGoogleMapsScriptLoaded = function(/*Function*/ aFunction)
{
    GoogleMapsScriptQueue.push(aFunction);

    performWhenGoogleMapsScriptLoaded = function()
    {
        GoogleMapsScriptQueue.push(aFunction);
    }

    // Maps is already loaded
    if (window.google && google.maps && google.maps.Map)
        _MKMapViewMapsLoaded();

    else
    {
        var DOMScriptElement = document.createElement("script");

        DOMScriptElement.src = "http://maps.google.com/maps/api/js?sensor=false&callback=_MKMapViewMapsLoaded";
        DOMScriptElement.type = "text/javascript";

        document.getElementsByTagName("head")[0].appendChild(DOMScriptElement);
    }
}

function _MKMapViewMapsLoaded()
{
    performWhenGoogleMapsScriptLoaded = function(/*Function*/ aFunction)
    {
        aFunction();
    }

    var index = 0,
        count = GoogleMapsScriptQueue.length;

    for (; index < count; ++index)
        GoogleMapsScriptQueue[index]();

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

var MKMapViewLocationKey    = @"MKMapViewLocationKey",
    MKMapViewZoomLevelKey   = @"MKMapViewZoomLevelKey";

@implementation MKMapView (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        [self setLocation:[aCoder decodeObjectForKey:MKMapViewLocationKey]];
        [self setZoomLevel:[aCoder decodeObjectForKey:MKMapViewZoomLevelKey]];

        [self _buildDOM];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:[self location] forKey:MKMapViewLocationKey];
    [aCoder encodeObject:[self zoomLevel] forKey:MKMapViewZoomLevelKey];
}

@end
