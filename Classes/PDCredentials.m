#import "PDCredentials.h"


@implementation PDCredentials

+ (PDCredentials *)credentialsWithUsername:(NSString *)username password:(NSString *)password deviceId:(NSString *)deviceId
{
	return [[[self alloc] initWithUsername:username password:password deviceId:deviceId] autorelease];
}

- (id)initWithUsername:(NSString *)username password:(NSString *)password deviceId:(NSString *)deviceId
{
	if (![super init])
		return nil;
	
	self.username = username;
	self.password = password;
	self.deviceId = deviceId;
	
	return self;
}

@end
