#import "NSString+Additions.h"

@implementation NSString (Additions)

- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
	CGSize constraint = CGSizeMake(width, 20000.0f);
	CGSize result = [self sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	return result.height;
}

@end
