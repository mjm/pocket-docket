#import "DOEntryTableCell.h"

#import "../Categories/NSString+Additions.h"

@implementation DOEntryTableCell

@synthesize checkboxButton, textLabel, commentLabel;

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
	
	NSLog(@"Setting frame.");
	self.commentLabel.frame = CGRectMake(15, 40, constraintWidth, height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	self.textLabel.highlighted = selected;
	self.commentLabel.highlighted = selected;
}

- (void)dealloc {
	self.checkboxButton = nil;
	self.textLabel = nil;
	self.commentLabel = nil;
	[super dealloc];
}

@end
