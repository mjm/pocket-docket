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
	
	[UIView beginAnimations:@"Editing" context:nil];
	[UIView setAnimationDuration:0.3];
	if (state == UITableViewCellStateShowingEditControlMask && !isIndented)
	{
		isIndented = YES;
		self.checkboxButton.alpha = 0;
		
		self.checkboxButton.frame = PDShiftRect(self.checkboxButton.frame, -32, NO);
		self.textLabel.frame = PDShiftRect(self.textLabel.frame, -32, YES);
	}
	else if (state == UITableViewCellStateDefaultMask && isIndented)
	{
		isIndented = NO;
		self.textLabel.frame = PDShiftRect(self.textLabel.frame, 32, YES);
	}
	[UIView commitAnimations];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
	[super didTransitionToState:state];
	if (state == UITableViewCellStateDefaultMask)
	{
		self.checkboxButton.frame = PDShiftRect(self.checkboxButton.frame, 32, NO);
		[UIView beginAnimations:nil context:nil];
		self.checkboxButton.alpha = 1;
		[UIView commitAnimations];
	}
}

- (void)dealloc
{
	self.checkboxButton = nil;
	self.textLabel = nil;
    [super dealloc];
}

@end
