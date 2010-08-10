#import "PDTextFieldCell.h"

@implementation PDTextFieldCell

+ (PDTextFieldCell *)textFieldCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDTextFieldCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect rect = self.textField.frame;
	if (!self.textLabel.text || [@"" isEqualToString:self.textLabel.text])
	{
		rect.origin.x = 10;
		rect.size.width = self.frame.size.width - 30;
	}
	else
	{
		rect.origin.x = 103;
		rect.size.width = self.frame.size.width - 123;
	}
	self.textField.frame = rect;
}

- (void)dealloc {
	self.textField = nil;
	self.textLabel = nil;
    [super dealloc];
}

@end
