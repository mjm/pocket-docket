#import "PDResource.h"

#import "NSObject+DeviceMethods.h"

#import "ObjectiveResource.h"
#import "Connection.h"
#import "Response.h"


@implementation PDResource

+ (NSString *)entityName
{
	return nil;
}

- (NSString *)entityName
{
	return [[self class] entityName];
}

+ (NSString *)getRemoteCollectionPath
{
	return [NSString stringWithFormat:@"%@?deviceId=%@", [super getRemoteCollectionPath], [[self class] deviceId]];
}

+ (NSString	*)getRemoteElementPath:(NSString *)elementId
{
	return [NSString stringWithFormat:@"%@?deviceId=%@", [super getRemoteElementPath:elementId], [[self class] deviceId]];
}

+ (NSString *)remoteElement:(NSString *)elementId pathForAction:(NSString *)action
{
	return [NSString stringWithFormat:@"%@%@/%@/%@%@?deviceId=%@",
			[self getRemoteSite],
			[self getRemoteCollectionName],
			elementId,
			action,
			[self getRemoteProtocolExtension],
			[self deviceId]];
}

- (NSString *)remoteElementPathForAction:(NSString *)action
{
	return [[self class] remoteElement:[self getRemoteId] pathForAction:action];
}

- (BOOL)moveRemoteWithResponse:(NSError **)aError
{
	NSString *movePath = [self remoteElementPathForAction:@"move"];
	Response *res = [Connection put:@"" to:movePath withUser:[[self class] getRemoteUser] andPassword:[[self class] getRemotePassword]];
	
	if (aError && [res isError])
		*aError = res.error;
	
	return [res isSuccess];
}

- (BOOL)gotMoveRemoteWithResponse:(NSError **)aError
{
	NSString *movePath = [self remoteElementPathForAction:@"got_move"];
	Response *res = [Connection put:@"" to:movePath withUser:[[self class] getRemoteUser] andPassword:[[self class] getRemotePassword]];
	
	if (aError && [res isError])
		*aError = res.error;
	
	return [res isSuccess];
}

@end
