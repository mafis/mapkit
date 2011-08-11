
@import <Foundation/CPObject.j>

@implementation MKPlacemark : CPObject
{
   CPDictionary adressDictionary @accessors(readonly);
   CLLocationCoordinate2D coordinate;
   CPString thoroughfare @accessors(readonly);
   CPString subThoroughfare @accessors(readonly);
   CPString locality @accessors(readonly);
   CPString subLocality @accessors(readonly);
   CPString administrativeArea @accessors(readonly);
   CPString subAdministrativeArea @accessors(readonly);
   CPString postalCode @accessors(readonly);
   CPString country @accessors(readonly);
   CPString countryCode @accessors(readonly);

   
   
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate addressDictionary:(CPDictionary)aAddressDictionary
{
    if (self = [super init])
    {
    	coordinate = aCoordinate;
        self.adressDictionary = aAddressDictionary;
                
        //Street and Streetnumber        
        if([adressDictionary containsKey:@"route"])
        {
	       [self setValue:[adressDictionary valueForKey:@"route"] forKey:@"thoroughfare"];
        }
        
        if([adressDictionary containsKey:@"street_number"])
        {
	       [self setValue:[adressDictionary valueForKey:@"street_number"] forKey:@"subThoroughfare"];
        }

        if([adressDictionary containsKey:@"locality"])
        {
	       [self setValue:[adressDictionary valueForKey:@"locality"] forKey:@"locality"];
        }

		if([adressDictionary containsKey:@"sublocality"])
        {
	       [self setValue:[adressDictionary valueForKey:@"sublocality"] forKey:@"subLocality"];
        }

        if([adressDictionary containsKey:@"administrative_area_level_1"])
        {
	       [self setValue:[adressDictionary valueForKey:@"administrative_area_level_1"] forKey:@"administrativeArea"];
        }


        if([adressDictionary containsKey:@"administrative_area_level_2"])
        {
	       [self setValue:[adressDictionary valueForKey:@"administrative_area_level_2"] forKey:@"subAdministrativeArea"];
        }

		if([adressDictionary containsKey:@"country"])
        {
	       [self setValue:[adressDictionary valueForKey:@"country"] forKey:@"country"];
        }


        if([adressDictionary containsKey:@"political"])
        {
	       [self setValue:[adressDictionary valueForKey:@"political"] forKey:@"countryCode"];
        }


        if([adressDictionary containsKey:@"postal_code"])
        {
	       [self setValue:[adressDictionary valueForKey:@"postal_code"] forKey:@"postalCode"];
        }
    }
    return self;
}









@end
