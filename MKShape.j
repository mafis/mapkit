@implementation MKShape : CPObject
{
	CPString *title @accessors();
    CPString *subtitle @accessorss();
}

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

@end