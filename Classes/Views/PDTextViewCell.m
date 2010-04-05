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
	[self.contentView addSubview:label];
	
	return self;
}

- (UILabel *)paragraphLabel {
	return (UILabel *) [self viewWithTag:1];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat width = self.frame.size.width;
	NSString *text = self.paragraphLabel.text;
	
	CGSize constraint = CGSizeMake(width - 40.0f, 20000.0f);
	CGSize size = [text sizeWithFont:self.paragraphLabel.font
				   constrainedToSize:constraint
					   lineBreakMode:UILineBreakModeWordWrap];
	
	self.paragraphLabel.frame = CGRectMake(10.0f, 10.0f, width - 40.0f, MAX(size.height, 44.0f));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
