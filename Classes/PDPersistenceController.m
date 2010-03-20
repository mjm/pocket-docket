#import "PDPersistenceController.h"

@implementation PDPersistenceController

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
	if (![super init])
		return;
	
	managedObjectContext = [context retain];
	return self;
}

@end
