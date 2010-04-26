
@import <AtlasKit/AtlasKit.j>

@implementation MapKitPlugin : AKPlugin
{
}

- (CPArray)libraryCibNames
{
    return [@"MapKitLibrary.cib"];
}

- (void)init
{
    self = [super init];

    if (self)
    {
        [_classDescriptions setObject:[CPDictionary dictionaryWithJSObject:{
            "ClassName"  : "MKMapView",
            "SuperClass" : "CPWebView",
            "Outlets"    : {
                            "delegate" : "id"
                           }
        } recursively:YES] forKey:@"MKMapView"];
    }

    return self;
}

@end
