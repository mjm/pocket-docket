#import "List.h"


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
	NSMethodSignature *sig = [self methodSignatureForSelector:@selector(findAllRemoteWithResponse:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:self];
	[invocation setSelector:@selector(findAllRemoteWithResponse:)];
	return invocation;
}

- (void)copyPropertiesTo:(NSManagedObject *)object
{
	[object setValue:self.listId forKey:@"remoteIdentifier"];
	[object setValue:self.title forKey:@"title"];
	[object setValue:self.position forKey:@"order"];
}

@end
