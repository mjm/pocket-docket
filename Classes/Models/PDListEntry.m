#import "PDListEntry.h"

@implementation PDListEntry

@dynamic text, comment, checked, order, remoteId, createdAt, updatedAt, list;

- (id)toResource
{
	return nil;
}

- (NSString *)plainTextString {
	NSString *check = [self.checked boolValue] ? @"X" : @"_";
	NSString *comm = (self.comment && [self.comment length] > 0)
			? [@"\n" stringByAppendingString:self.comment]
			: @"";
	return [NSString stringWithFormat:@"[%@] %@%@", check, self.text, comm];
}

@end
