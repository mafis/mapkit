// MKMapViewAttributeInspector.j
// MapKitPlugin
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

@import <AtlasKit/AtlasKit.j>


@implementation MKMapViewAttributeInspector : AKInspector
{
    @outlet CPTextField     latitudeField;
    @outlet CPTextField     longitudeField;
    @outlet CPPopUpButton   mapTypePopUpButton;
}

- (void)awakeFromCib
{
    [mapTypePopUpButton removeAllItems];

    [mapTypePopUpButton addItemWithTitle:@"Map"];
    [[mapTypePopUpButton lastItem] setTag:MKMapTypeStandard];
    [mapTypePopUpButton addItemWithTitle:@"Satellite"];
    [[mapTypePopUpButton lastItem] setTag:MKMapTypeSatellite];
    [mapTypePopUpButton addItemWithTitle:@"Hybrid"];
    [[mapTypePopUpButton lastItem] setTag:MKMapTypeHybrid];
    [mapTypePopUpButton addItemWithTitle:@"Terrain"];
    [[mapTypePopUpButton lastItem] setTag:MKMapTypeTerrain];
}

- (CPString)label
{
    return @"Map View";
}

- (CPString)viewCibName
{
    return @"MKMapViewAttributeInspector";
}

- (void)refresh
{
    var inspectedObjects = [self inspectedObjects];

    [latitudeField takeValueFromKeyPath:@"centerCoordinateLatitude" ofObjects:inspectedObjects];
    [longitudeField takeValueFromKeyPath:@"centerCoordinateLongitude" ofObjects:inspectedObjects];
    [mapTypePopUpButton takeValueFromKeyPath:@"mapType" ofObjects:inspectedObjects];
}

- (@action)takeStringAddressFrom:(CPSearchField)aSearchField
{
    [[self inspectedObjects] makeObjectsPerformSelector:@selector(takeStringAddressFrom:) withObject:aSearchField];
}

- (@action)takeLatitudeFrom:(CPTextField)aTextField
{
    [[self inspectedObjects] makeObjectsPerformSelector:@selector(setCenterCoordinateLatitude:) withObject:[aTextField floatValue]];
}

- (@action)takeLongitudeFrom:(CPTextField)aTextField
{
    [[self inspectedObjects] makeObjectsPerformSelector:@selector(setCenterCoordinateLongitude:) withObject:[aTextField floatValue]];
}

- (@action)takeMapTypeFrom:(id)aPopUpButton
{
    [[self inspectedObjects] makeObjectsPerformSelector:@selector(setMapType:) withObject:[[aPopUpButton selectedItem] tag]];
}

@end
