#import "Entry.h"

#import "List.h"
#import "ObjectiveResource.h"
#import "Connection.h"
#import "Response.h"
#import "JSONFramework.h"

@implementation Entry

+ (NSString *)entityName
{
	return @"ListEntry";
}

+ (NSString *)getRemoteCollectionName
{
	// ObjectiveResource does dumb pluralization, so we override it
	return @"entries";
}

+ (NSString *)getRemoteCollectionPathForList:(NSString *)listId
{
	return [NSString stringWithFormat:@"%@%@/%@/%@%@?deviceId=%@",
			[[self class] getRemoteSite],
			[List getRemoteCollectionName],
			listId,
			[[self class] getRemoteCollectionName],
			[[self class] getRemoteProtocolExtension],
			[[self class] deviceId]];
}

- (NSString *)getRemoteCollectionPath
{
	return [[self class] getRemoteCollectionPathForList:self.listId];
}

- (NSString *)getRemoteElementPath
{
	return [NSString stringWithFormat:@"%@%@/%@/%@/%@%@?deviceId=%@",
			[[self class] getRemoteSite],
			[List getRemoteCollectionName],
			self.listId,
			[[self class] getRemoteCollectionName],
			self.entryId,
			[[self class] getRemoteProtocolExtension],
			[[self class] deviceId]];
}

- (NSString *)remoteElementPathForAction:(NSString *)action
{
	return [NSString stringWithFormat:@"%@%@/%@/%@/%@/%@%@?deviceId=%@",
			[[self class] getRemoteSite],
			[List getRemoteCollectionName],
			self.listId,
			[[self class] getRemoteCollectionName],
			self.entryId,
			action,
			[[self class] getRemoteProtocolExtension],
			[[self class] deviceId]];
}

- (BOOL)updateRemoteWithResponse:(NSError **)aError
{
	return [self updateRemoteAtPath:[self getRemoteElementPath] withResponse:aError];
}

- (BOOL)destroyRemoteWithResponse:(NSError **)aError
{
	return [self destroyRemoteAtPath:[self getRemoteElementPath] withResponse:aError];
}

+ (BOOL)sortRemote:(NSArray *)ids forList:(NSString *)listId withResponse:(NSError **)aError
{
	NSString *sortPath = [NSString stringWithFormat:@"%@%@/%@/%@/sort%@",
						  [self getRemoteSite],
						  [List getRemoteCollectionName],
						  listId,
						  [self getRemoteCollectionName],
						  [self getRemoteProtocolExtension]];
	
	NSDictionary *bodyDict = [NSDictionary dictionaryWithObject:ids forKey:@"ids"];
	NSString *body = [bodyDict JSONRepresentation];
	
	Response *res = [Connection put:body to:sortPath withUser:[self getRemoteUser] andPassword:[self getRemotePassword]];
	if (aError && [res isError])
		*aError = res.error;
	
	return [res isSuccess];
}

+ (NSArray *)findAllRemoteInList:(NSString *)listId withResponse:(NSError **)aError
{
	Response *res = [Connection get:[self getRemoteCollectionPathForList:listId] withUser:[[self class] getRemoteUser] andPassword:[[self class]  getRemotePassword]];
	if([res isError] && aError) {
		*aError = res.error;
		return nil;
	}
	else {
		return [self performSelector:[self getRemoteParseDataMethod] withObject:res.body];
	}
}

@end
