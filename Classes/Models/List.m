#import "List.h"

#import "ObjectiveResource.h"
#import "Connection.h"
#import "Response.h"
#import "JSONFramework.h"

@implementation List

- (NSString *)description
{
	return [NSString stringWithFormat:@"<List:%@ title=%@, position=%@, userId=%@>",
			self.listId, self.title, self.position, self.userId];
}

+ (NSString *)entityName
{
	return @"List";
}

+ (NSInvocation *)findAllRemoteInvocation
{
	NSMethodSignature *sig = [self methodSignatureForSelector:@selector(findAllRemote)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:[self class]];
	[invocation setSelector:@selector(findAllRemote)];
	return invocation;
}

//- (void)copyPropertiesTo:(NSManagedObject *)object
//{
//	[object setValue:self.listId forKey:@"remoteIdentifier"];
//	[object setValue:self.title forKey:@"title"];
//	[object setValue:self.position forKey:@"order"];
//}

+ (BOOL)sortRemote:(NSArray *)ids withResponse:(NSError **)aError
{
	NSString *sortPath = [NSString stringWithFormat:@"%@%@/sort%@",
						  [self getRemoteSite],
						  [self getRemoteCollectionName],
						  [self getRemoteProtocolExtension]];
	
	NSDictionary *bodyDict = [NSDictionary dictionaryWithObject:ids forKey:@"ids"];
	NSString *body = [bodyDict JSONRepresentation];
	
	Response *res = [Connection put:body to:sortPath withUser:[self getRemoteUser] andPassword:[self getRemotePassword]];
	if (aError && [res isError])
		*aError = res.error;
	
	return [res isSuccess];
}

@end
