#import "PDListTableCell.h"

@implementation PDListTableCell

+ (PDListTableCell *)listTableCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDListTableCell" owner:self options:nil];
	PDListTableCell *cell = [objects objectAtIndex:0];
	[cell setIsAccessibilityElement:YES];
	return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	self.titleLabel.highlighted = selected;
	self.completionLabel.highlighted = selected;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	UIImage *image = [UIImage imageNamed:@"ListCell.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	imageView.image = image;
	self.backgroundView = imageView;
	[imageView release];
}

- (void)dealloc {
	self.progressView = nil;
	self.titleLabel = nil;
	self.completionLabel = nil;
    [super dealloc];
}


@end
