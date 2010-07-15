#import "PDEntryTableCell.h"

CGRect PDShiftRect(CGRect rect, NSInteger distance, BOOL changeWidth)
{
	CGRect shifted = rect;
	shifted.origin.x += distance;
	if (changeWidth)
		shifted.size.width -= distance;
	return shifted;
}

@implementation PDEntryTableCell

+ (PDEntryTableCell *)entryTableCell
{
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDEntryTableCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.textLabel.highlighted = selected;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
	[super willTransitionToState:state];
	
	if (state == UITableViewCellStateShowingEditControlMask && !isIndented)
	{
		isIndented = YES;
		self.checkboxImage.alpha = 0;
		self.checkboxButton.alpha = 0;
		self.textLabel.frame = PDShiftRect(self.textLabel.frame, -32, YES);
	}
	else if (state == UITableViewCellStateDefaultMask && isIndented)
	{
		isIndented = NO;
		self.checkboxImage.alpha = 1;
		self.checkboxButton.alpha = 1;
		self.textLabel.frame = PDShiftRect(self.textLabel.frame, 32, YES);
	}
}

- (void)dealloc
{
	self.checkboxButton = nil;
	self.textLabel = nil;
    [super dealloc];
}

@end
