
function MKCoordinateSpan(/*CLLocationDegrees*/ aLatitudeDelta, /*CLLocationDegrees*/ aLongitudeDelta)
{
    this.latitudeDelta = aLatitudeDelta;
    this.longitudeDelta = aLongitudeDelta;

    return this;
}

MKCoordinateSpan.prototype.toString = function()
{
    return "{" + this.latitudeDelta + ", " + this.longitudeDelta + "}";
}

function MKCoordinateSpanMake(/*CLLocationDegrees*/ aLatitudeDelta, /*CLLocationDegrees*/ aLongitudeDelta)
{
    return new MKCoordinateSpan(aLatitudeDelta, aLongitudeDelta);
}

function MKCoordinateSpanFromLatLng(/*LatLng*/ aLatLng)
{
    return new MKCoordinateSpan(aLatLng.lat(), aLatLng.lng());
}

function CLLocationCoordinate2D(/*CLLocationDegrees*/ aLatitude, /*CLLocationDegrees*/ aLongitude)
{
    if (arguments.length === 1)
    {
        var coordinate = arguments[0];

        this.latitude = coordinate.latitude;
        this.longitude = coordinate.longitude;
    }
    else
    {
        this.latitude = +aLatitude || 0;
        this.longitude = +aLongitude || 0;
    }

    return this;
}

function CPStringFromCLLocationCoordinate2D(/*CLLocationCoordinate2D*/ aCoordinate)
{
    return "{" + aCoordinate.latitude + ", " + aCoordinate.longitude + "}";
}

function CLLocationCoordinate2DFromString(/*String*/ aString)
{
    var comma = aString.indexOf(',');

    return new CLLocationCoordinate2D(
        parseFloat(aString.substr(1, comma - 1)), 
        parseFloat(aString.substring(comma + 1, aString.length)));
}

CLLocationCoordinate2D.prototype.toString = function()
{
    return CPStringFromCLLocationCoordinate2D(this);
}

function CLLocationCoordinate2DMake(/*CLLocationDegrees*/ aLatitude, /*CLLocationDegrees*/ aLongitude)
{
    return new CLLocationCoordinate2D(aLatitude, aLongitude);
}

function CLLocationCoordinate2DFromLatLng(/*LatLng*/ aLatLng)
{
    return new CLLocationCoordinate2D(aLatLng.lat(), aLatLng.lng());
}

function LatLngFromCLLocationCoordinate2D(/*CLLocationCoordinate2D*/ aLocation)
{
    return new google.maps.LatLng(aLocation.latitude, aLocation.longitude);
}

function MKCoordinateRegion(/*CLLocationCoordinate2D*/ aCenter, /*MKCoordinateSpan*/ aSpan)
{
    this.center = aCenter;
    this.span = aSpan;

    return this;
}

MKCoordinateRegion.prototype.toString = function()
{
    return "{" + 
            this.center.latitude + ", " + 
            this.center.longitude + ", " + 
            this.span.latitudeDelta + ", " + 
            this.span.longitudeDelta + "}";
}

function MKCoordinateRegionMake(/*CLLocationCoordinate2D*/ aCenter, /*MKCoordinateSpan*/ aSpan)
{
    return new MKCoordinateRegion(aCenter, aSpan);
}

function MKCoordinateRegionFromLatLngBounds(/*LatLngBounds*/ bounds)
{
    return new MKCoordinateRegion(
        CLLocationCoordinate2DFromLatLng(bounds.getCenter()), 
        MKCoordinateSpanFromLatLng(bounds.toSpan()));
}

function LatLngBoundsFromMKCoordinateRegion(/*MKCoordinateRegion*/ aRegion)
{
    var latitude = aRegion.center.latitude,
        longitude = aRegion.center.longitude,
        latitudeDelta = aRegion.span.latitudeDelta,
        longitudeDelta = aRegion.span.longitudeDelta,
        LatLng = google.maps.LatLng,
        LatLngBounds = google.maps.LatLngBounds;

    return new LatLngBounds(
        new LatLng(latitude - latitudeDelta / 2, longitude - longitudeDelta / 2), // SW
        new LatLng(latitude + latitudeDelta / 2, longitude + longitudeDelta / 2) // NE
        );
}
