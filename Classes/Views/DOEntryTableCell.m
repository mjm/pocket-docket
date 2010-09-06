#import "DOEntryTableCell.h"

#import "../Categories/NSString+Additions.h"

CGRect PDShiftRect(CGRect rect, NSInteger distance, BOOL changeWidth)
{
	CGRect shifted = rect;
	shifted.origin.x += distance;
	if (changeWidth)
		shifted.size.width -= distance;
	return shifted;
}

@implementation DOEntryTableCell

+ (DOEntryTableCell *)entryTableCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DOEntryTableCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (self.editing)
		return;
	
	CGFloat constraintWidth = self.frame.size.width - ENTRY_CELL_OFFSET;
	CGFloat height = [self.commentLabel.text heightWithFont:self.commentLabel.font
										 constrainedToWidth:constraintWidth];
	
	self.commentLabel.frame = CGRectMake(53, 40, constraintWidth, height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	self.entryLabel.highlighted = selected;
	self.commentLabel.highlighted = selected;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
	[super willTransitionToState:state];
	
	if (state == UITableViewCellStateShowingEditControlMask && !isIndented)
	{
		isIndented = YES;
		self.checkboxImage.alpha = 0;
		self.checkboxButton.alpha = 0;
		self.entryLabel.frame = PDShiftRect(self.entryLabel.frame, -32, YES);
		self.commentLabel.frame = PDShiftRect(self.commentLabel.frame, -32, YES);
	}
	else if (state == UITableViewCellStateDefaultMask && isIndented)
	{
		isIndented = NO;
		self.checkboxImage.alpha = 1;
		self.checkboxButton.alpha = 1;
		self.entryLabel.frame = PDShiftRect(self.entryLabel.frame, 32, YES);
		self.commentLabel.frame = PDShiftRect(self.commentLabel.frame, 32, YES);
	}
}

- (void)dealloc {
	self.checkboxButton = nil;
	self.entryLabel = nil;
	self.commentLabel = nil;
	[super dealloc];
}

@end
