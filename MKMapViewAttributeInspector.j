
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
