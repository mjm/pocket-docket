#import "PDTextViewCell.h"

@implementation PDTextViewCell

- (id)initWithReuseIdentifier:(NSString *)identifier {
	if (![super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])
		return nil;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.minimumFontSize = 17.0f;
	label.numberOfLines = 0;
	label.font = [UIFont systemFontOfSize:17.0f];
	label.tag = 1;
	label.highlightedTextColor = [UIColor whiteColor];
	[self.contentView addSubview:label];
	[label release];
	
	return self;
}

- (UILabel *)paragraphLabel {
	return (UILabel *) [self viewWithTag:1];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (!self.paragraphLabel.text)
		self.paragraphLabel.frame = CGRectMake(10.0f, 10.0f, 10.0f, 24.0f);
	
	CGFloat width = self.frame.size.width;
	NSString *text = self.paragraphLabel.text;
	
	CGSize constraint = CGSizeMake(width - 45.0f, 20000.0f);
	CGSize size = [text sizeWithFont:self.paragraphLabel.font
				   constrainedToSize:constraint
					   lineBreakMode:UILineBreakModeWordWrap];
	
	self.paragraphLabel.frame = CGRectMake(10.0f, 10.0f, width - 45.0f, MAX(size.height, 24.0f));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.paragraphLabel.highlighted = selected;
}

- (void)dealloc {
    [super dealloc];
}

@end
