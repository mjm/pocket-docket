#import "PDListEntry.h"

@implementation PDListEntry

- (NSString *)plainTextString {	
	NSString *check = [self.checked boolValue] ? @"X" : @"_";
	NSString *comm = (self.comment && [self.comment length] > 0)
	? [@"\n" stringByAppendingString:self.comment]
	: @"";
	return [NSString stringWithFormat:@"[%@] %@%@", check, self.text, comm];
}

@end
