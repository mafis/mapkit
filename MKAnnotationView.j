@implementation MKAnnotationView : CPView
{
	BOOL enabled @accessors(getter=isEnabled);	
	BOOL highlighted @accessors(getter=isHighlighted);
	CPImage image @accessors();
	CPView leftCalloutAccessoryView @accessors();
	CPString reuseIdentifier @accessors(readonly);
	CPView rightCalloutAccessoryView @accessors();
	BOOL selected @accessors(getter=isSelected);
	MKAnnotation annotation @accessors();
	CPPoint calloutOffset @accessors();
	BOOL canShowCallout @accessors();
	CPPoint centerOffset @accessors();
	BOOL draggable @accessors(getter=isDraggable);
	
	id delegate @accessors();
	
	//TODO : Dragstate
	
	CPImageView _imageView;
}

- (id)initWithAnnotation:(MKAnnotation)aAnnotation reuseIdentifer:(CPString)aIdentfier
{
	if(self = [super init])
	{
		self.annotation = aAnnotation;
		self.draggable = NO;
		self.enabled = YES;
		self.leftCalloutAccessoryView = nil;
		self.rightCalloutAccessoryView = nil;
	}
	return self;
}

- (void)prepareForReuse
{
	
}

-(void)setImage:(CPImage)aImage
{
	if(!_imageView)
	{
		_imageView = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,0,0)];
		[self addSubview:_imageView];
	}
	
	[aImage setDelegate:self];
	image = aImage;
	[_imageView setImage:image];

}

-(void)imageDidLoad:(CPImage)aImage
{
	var imageSize = CPSizeMake([aImage size].width, [aImage size].width);

	[self setFrameSize:imageSize];
	[_imageView setFrameSize:imageSize];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	
}

/*
- (void)setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
	
}*/


- (void)mouseDown:(CPEvent)anEvent	
{

	//Only send Mouse Events, if annotationView is enabled
	if(enabled && [delegate respondsToSelector:@selector(annotationViewdidSelected:)])
	{
		

	CPLog.debug("Mouse Down on MKAnnotationView");
		[delegate annotationViewdidSelected:self]
	}
}


@end