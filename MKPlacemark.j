
@import <Foundation/CPObject.j>

@implementation MKPlacemark : CPObject
{
   CPDictionary adressDictionary @accessors;
   CLLocationCoordinate2D coordinate;
   CPString thoroughfare @accessors();
   CPString subThoroughfare @accessors();
   CPString locality @accessors();
   CPString subLocality @accessors();
   CPString administrativeArea @accessors();
   CPString subAdministrativeArea @accessors();
   CPString postalCode @accessors();
   CPString country @accessors();
   CPString countryCode @accessors();

   
   
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate addressDictionary:(CPDictionary)aAddressDictionary
{
    if (self = [super init])
    {
    	coordinate = aCoordinate;
        self.adressDictionary = aAddressDictionary;
    }
    return self;
}









@end
