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
	
	// Now update the order of all the other lists.
	NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"allLists"];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results) {
		for (PDList *each in results) {
			if (![each isEqual:list]) {
				each.order = [NSNumber numberWithInteger:[each.order integerValue] + 1];
			}
		}
		
		[self save];
	} else {
		NSLog(@"Error when retrieving lists to increment order, %@, %@", error, [error userInfo]);
	}
	
	return list;
}

#pragma mark -
#pragma mark Manipulating Model Objects

- (void)moveList:(PDList *)list fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow {
	if (fromRow == toRow)
		return;
	
	NSUInteger minRow = MIN(fromRow, toRow);
	NSUInteger maxRow = MAX(fromRow, toRow);
	
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInteger:minRow], @"MIN_ROW",
						  [NSNumber numberWithInteger:maxRow], @"MAX_ROW", nil];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"listsBetween"
																  substitutionVariables:vars];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *records = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (records) {
		NSUInteger index = (minRow == fromRow) ? minRow : minRow + 1;
		for (PDList *each in records) {
			if ([each isEqual:list]) {
				each.order = [NSNumber numberWithInteger:toRow];
			} else {
				each.order = [NSNumber numberWithInteger:index];
				index++;
			}
		}
		
		[self save];
	} else {
		NSLog(@"Error retrieving objects to reorder: %@, %@", error, [error userInfo]);
	}
}

#pragma mark -
#pragma mark Deleting Model Objects

- (void)deleteList:(PDList *)list {
	NSNumber *position = list.order;
	[self.managedObjectContext deleteObject:list];
	
	NSDictionary *vars = [NSDictionary dictionaryWithObject:position forKey:@"POSITION"];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"listsAbove"
																  substitutionVariables:vars];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results) {
		for (PDList *each in results) {
			each.order = [NSNumber numberWithInteger:[each.order integerValue] - 1];
		}
		
		[self save];
	} else {
		NSLog(@"Error retrieving objects with higher order, %@, %@", error, [error userInfo]);
	}
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
