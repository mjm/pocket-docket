#import "PDCredentials.h"


@implementation PDCredentials

+ (PDCredentials *)credentialsWithUsername:(NSString *)aUsername password:(NSString *)aPassword deviceId:(NSString *)aDeviceId
{
	return [[[self alloc] initWithUsername:aUsername password:aPassword deviceId:aDeviceId] autorelease];
}

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword deviceId:(NSString *)aDeviceId
{
	if (![super init])
		return nil;
	
	self.username = aUsername;
	self.password = aPassword;
	self.deviceId = aDeviceId;
	
	return self;
}

@end
