
@import "MKMapViewAttributeInspector.j"

@implementation MKMapView (Integration)

- (void)atlasPopulateKeyPaths:(CPMutableDictionary)keyPaths
{
    [super atlasPopulateKeyPaths:keyPaths];

    [[keyPaths objectForKey:AKAttributeKeyPaths] addObjectsFromArray:[
        @"centerCoordinate",
        @"zoomLevel",
        @"scrollWheelZoomEnabled",
        @"mapType"]];
}

- (void)atlasPopulateAttributeInspectorClasses:(CPMutableArray)classes
{
    [super atlasPopulateAttributeInspectorClasses:classes];

    [classes addObject:[MKMapViewAttributeInspector class]];
}

@end
