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
	if (!self.label.text || [@"" isEqualToString:self.label.text])
	{
		rect.origin.x = 10;
		rect.size.width = self.frame.size.width - 30 - leftIndent;
	}
	else
	{
		rect.origin.x = 103;
		rect.size.width = self.frame.size.width - 123 - leftIndent;
	}
	self.textField.frame = rect;
}

- (void)dealloc {
	self.textField = nil;
	self.label = nil;
    [super dealloc];
}

@end
