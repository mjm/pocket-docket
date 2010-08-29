#import "PDListEntry.h"
#import "PDList.h"
#import "Entry.h"

@implementation PDListEntry

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


// This shouldn't be necessary but MOGenerator is screwing up

@dynamic updatedSinceSync;



- (BOOL)updatedSinceSyncValue {
	NSNumber *result = [self updatedSinceSync];
	return [result boolValue];
}

- (void)setUpdatedSinceSyncValue:(BOOL)value_ {
	[self setUpdatedSinceSync:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveUpdatedSinceSyncValue {
	NSNumber *result = [self primitiveUpdatedSinceSync];
	return [result boolValue];
}

- (void)setPrimitiveUpdatedSinceSyncValue:(BOOL)value_ {
	[self setPrimitiveUpdatedSinceSync:[NSNumber numberWithBool:value_]];
}

@end
