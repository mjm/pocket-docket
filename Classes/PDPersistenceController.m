#import "PDPersistenceController.h"

@implementation PDPersistenceController

@synthesize managedObjectContext;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
	if (![super init])
		return nil;
	
	managedObjectContext = [context retain];
	return self;
}

- (void)dealloc {
	[managedObjectContext release];
	[super dealloc];
}

@end
