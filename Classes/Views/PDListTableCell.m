#import "PDListTableCell.h"

@interface PDListTableCell (PrivateMethods)

- (void)setHighlightedAppearance;
- (void)setUnhighlightedAppearance;

@end

@implementation PDListTableCell (PrivateMethods)

- (void)setHighlightedAppearance {
	self.titleLabel.highlighted = YES;
	self.completionLabel.highlighted = YES;
}

- (void)setUnhighlightedAppearance {
	self.titleLabel.highlighted = NO;
	self.completionLabel.highlighted = NO;
}

@end


@implementation PDListTableCell

@synthesize progressView, titleLabel, completionLabel;

+ (PDListTableCell *)listTableCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDListTableCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	if (selected) {
		[self setHighlightedAppearance];
	} else {
		[self setUnhighlightedAppearance];
	}
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (highlighted) {
		[self setHighlightedAppearance];
	} else {
		[self setUnhighlightedAppearance];
	}
}

- (void)dealloc {
	self.progressView = nil;
	self.titleLabel = nil;
	self.completionLabel = nil;
    [super dealloc];
}


@end
