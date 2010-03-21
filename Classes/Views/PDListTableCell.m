#import "PDListTableCell.h"

@implementation PDListTableCell

@synthesize imageView, titleLabel, completionLabel;

+ (PDListTableCell *)listTableCell {
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PDListTableCell" owner:self options:nil];
	return [objects objectAtIndex:0];
}

- (void)dealloc {
	self.imageView = nil;
	self.titleLabel = nil;
	self.completionLabel = nil;
    [super dealloc];
}


@end
