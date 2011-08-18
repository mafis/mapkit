// MKGeometry.j
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

function CLLocationCoordinate2DEqualToCLLocationCoordinate2D(/*CLLocationCoordinate2D*/ lhs, /*CLLocationCoordinate2D*/ rhs)
{
    return lhs === rhs || lhs.latitude === rhs.latitude && lhs.longitude === rhs.longitude;
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

function MKMapPoint(/* double*/ x, /*double*/ y)
{
	this.x = x;
    this.y = y;

    return this;
}

function MKMapPointMake(/* double*/ x, /*double*/ y)
{
	return new MKMapPoint(x,y);
}


function MKMapSize(/* double*/ width, /*double*/ height)
{
	this.width = width;
    this.height = height;

    return this;
}

function MKMapSizeMake(/* double*/ width, /*double*/ height)
{
	return new MKMapSize(width,height);
}

function MKMapRect(/* MKMapPoint*/ origin, /*MKMapSize*/ size)
{
	this.origin = origin;
    this.size = size;

    return this;
}

function MKMapRectMake(/* double*/ x, /*double*/ y, /*double*/ width ,/*double*/ height)
{
	return new MKMapRect(MKMapPointMake(x,y),MKMapSizeMake(width,height));
}

MKMapRect.prototype.toString = function()
{
    return "{" + 
            this.origin.x + ", " + 
            this.origin.y + ", " + 
            this.size.width + ", " + 
            this.size.height + "}";
}

