#import "PDDeviceResource.h"
#import "NSObject+DeviceMethods.h"
#import "ObjectiveResource.h"

@implementation PDDeviceResource

+ (NSString *)getRemoteCollectionPath
{
	return [NSString stringWithFormat:@"%@?deviceId=%@", [super getRemoteCollectionPath], [[self class] deviceId]];
}

+ (NSString	*)getRemoteElementPath:(NSString *)elementId
{
	return [NSString stringWithFormat:@"%@?deviceId=%@", [super getRemoteElementPath:elementId], [[self class] deviceId]];
}

@end
