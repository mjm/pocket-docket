#import "PDEntryTableCell.h"

@implementation PDEntryTableCell

@synthesize checkboxButton, textLabel;

+ (PDEntryTableCell *)entryTableCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDEntryTableCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.textLabel.highlighted = selected;
}

- (void)dealloc {
	self.checkboxButton = nil;
	self.textLabel = nil;
    [super dealloc];
}

@end
