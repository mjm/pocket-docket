#import "PDListTableCell.h"

@implementation PDListTableCell

@synthesize imageView, progressView, titleLabel, completionLabel;

+ (PDListTableCell *)listTableCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDListTableCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	self.imageView.hidden = selected;
	self.titleLabel.highlighted = selected;
	self.completionLabel.highlighted = selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	self.imageView.hidden = highlighted;
}

- (void)dealloc {
	self.progressView = nil;
	self.titleLabel = nil;
	self.completionLabel = nil;
    [super dealloc];
}


@end
