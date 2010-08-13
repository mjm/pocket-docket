#import "PDListEntry.h"

#import "PDList.h"
#import "Entry.h"

@implementation PDListEntry

@dynamic text, comment, checked, order, remoteIdentifier, createdAt, updatedAt, list;

- (id)toResource
{
	Entry *entry = [[Entry alloc] init];
	entry.entryId = self.remoteIdentifier;
	entry.listId = self.list.remoteIdentifier;
	entry.text = self.text;
	entry.comment = self.comment;
	entry.checked = self.checked;
	entry.position = self.order;
	return [entry autorelease];
}

- (NSString *)plainTextString {
	NSString *check = [self.checked boolValue] ? @"X" : @"_";
	NSString *comm = (self.comment && [self.comment length] > 0)
			? [@"\n" stringByAppendingString:self.comment]
			: @"";
	return [NSString stringWithFormat:@"[%@] %@%@", check, self.text, comm];
}

@end
