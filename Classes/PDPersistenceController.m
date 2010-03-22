#import "PDPersistenceController.h"

#import "Models/PDList.h"

#pragma mark PrivateMethods

@interface PDPersistenceController (PrivateMethods)

@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

@end

@implementation PDPersistenceController (PrivateMethods)

- (NSManagedObjectModel *)managedObjectModel {
	return self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
}

@end

#pragma mark -

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

#pragma mark -
#pragma mark Retrieving Model Objects

- (NSFetchedResultsController *)listsFetchedResultsController {
	NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"allLists"];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	return [[[NSFetchedResultsController alloc] initWithFetchRequest:request
												managedObjectContext:self.managedObjectContext
												  sectionNameKeyPath:nil
														   cacheName:nil] autorelease];
}

#pragma mark -
#pragma mark Creating Model Objects

- (PDList *)createList {
	PDList *list = [NSEntityDescription insertNewObjectForEntityForName:@"List"
												 inManagedObjectContext:self.managedObjectContext];
	list.order = [NSNumber numberWithInteger:0];
	return list;
}

#pragma mark -
#pragma mark Deleting Model Objects

- (void)deleteList:(PDList *)list {
	[self.managedObjectContext deleteObject:list];
}

#pragma mark -
#pragma mark Saving Changes

- (void)save {
	NSError *error;
	
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Error saving changes: %@, %@", error, [error userInfo]);
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[managedObjectContext release];
	[super dealloc];
}

@end
