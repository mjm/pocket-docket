#import "Entry.h"
#import "List.h"

@implementation Entry

+ (NSString *)getRemoteCollectionName
{
	// ObjectiveResource does dumb pluralization, so we override it
	return @"entries";
}

- (NSString *)getRemoteCollectionPath
{
	return [NSString stringWithFormat:@"%@%@/%@/%@%@",
			[[self class] getRemoteSite],
			[List getRemoteCollectionName],
			self.listId,
			[[self class] getRemoteCollectionName],
			[[self class] getRemoteProtocolExtension]];
}

- (NSString *)getRemoteElementPath
{
	return [NSString stringWithFormat:@"%@%@/%@/%@/%@%@",
			[[self class] getRemoteSite],
			[List getRemoteCollectionName],
			self.listId,
			[[self class] getRemoteCollectionName],
			self.entryId,
			[[self class] getRemoteProtocolExtension]];
}

- (BOOL)updateRemoteWithResponse:(NSError **)aError
{
	return [self updateRemoteAtPath:[self getRemoteElementPath] withResponse:aError];
}

- (BOOL)destroyRemoteWithResponse:(NSError **)aError
{
	return [self destroyRemoteAtPath:[self getRemoteElementPath] withResponse:aError];
}

@end
