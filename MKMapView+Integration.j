
@import "MKMapViewAttributeInspector.j"

@implementation MKMapView (Integration)

- (void)atlasPopulateKeyPaths:(CPMutableDictionary)keyPaths
{
    [super atlasPopulateKeyPaths:keyPaths];

    [[keyPaths objectForKey:AKAttributeKeyPaths] addObjectsFromArray:[
        @"location",
        @"zoomLevel",
        @"scrollWheelZoomEnabled"]];
}

- (void)atlasPopulateAttributeInspectorClasses:(CPMutableArray)classes
{
    [super atlasPopulateAttributeInspectorClasses:classes];

    [classes addObject:[MKMapViewAttributeInspector class]];
}

@end
