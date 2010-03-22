#import "PDTextFieldCell.h"

@implementation PDTextFieldCell

@synthesize textField;

+ (PDTextFieldCell *)textFieldCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDTextFieldCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)dealloc {
	self.textField = nil;
    [super dealloc];
}

@end
