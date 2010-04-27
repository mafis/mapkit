
@import <AtlasKit/AtlasKit.j>


@implementation MKMapViewAttributeInspector : AKInspector
{
    @outlet CPTextField latitudeField;
    @outlet CPTextField longitudeField;
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

    [latitudeField takeValueFromKeyPath:@"locationLatitude" ofObjects:inspectedObjects];
    [longitudeField takeValueFromKeyPath:@"locationLongitude" ofObjects:inspectedObjects];
}

- (@action)takeLatitudeFrom:(CPTextField)aTextField
{
    [[self inspectedObjects] makeObjectsPerformSelector:@selector(setLocationLatitude:) withObject:[aTextField floatValue]];
}

- (@action)takeLongitudeFrom:(CPTextField)aTextField
{
    [[self inspectedObjects] makeObjectsPerformSelector:@selector(setLocationLongitude:) withObject:[aTextField floatValue]];
}

- (@action)takeStringAddressFrom:(CPSearchField)aSearchField
{
    [[self inspectedObjects] makeObjectsPerformSelector:@selector(takeStringAddressFrom:) withObject:aSearchField];
}

@end
