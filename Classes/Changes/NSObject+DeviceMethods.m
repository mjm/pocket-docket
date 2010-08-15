#import "NSObject+DeviceMethods.h"

static NSString * _activeDeviceId;

@implementation NSObject (DeviceMethods)

+ (NSString *)deviceId
{
	return _activeDeviceId;
}

+ (void)setDeviceId:(NSString *)deviceId
{
	if (deviceId != _activeDeviceId)
	{
		[_activeDeviceId release];
		_activeDeviceId = [deviceId retain];
	}
}

@end
