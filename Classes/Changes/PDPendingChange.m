#import "PDPendingChange.h"

#import "../Categories/NSManagedObject+Additions.h"

@implementation PDPendingChange

- (id)initWithManagedObject:(NSManagedObject <PDLocalChanging> *)object changeType:(NSString *)changeType
{
	if (![super init])
		return nil;
	
	self.changed = object;
	self.objectID = [object objectIDString];
	self.remoteID = [NSString stringWithFormat:@"%@:%@", NSStringFromClass([[object toResource] class]), [object remoteIdentifier]];
	self.changeType = changeType;
	
	return self;
}

- (void)dealloc
{
	self.changed = nil;
	self.objectID = nil;
	self.remoteID = nil;
	self.changeType = nil;
	[super dealloc];
}

@end