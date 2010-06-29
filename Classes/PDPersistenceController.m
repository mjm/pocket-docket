#import "PDPersistenceController.h"

#import "SynthesizeSingleton.h"
#import "PDSettingsController.h"
#import "Models/PDList.h"
#import "Models/PDListEntry.h"

#pragma mark PrivateMethods

@interface PDPersistenceController ()

@property (nonatomic, readonly) NSUndoManager *undoManager;
- (NSString *)applicationDocumentsDirectory;

@end

#pragma mark -

@implementation PDPersistenceController

SYNTHESIZE_SINGLETON_FOR_CLASS(PDPersistenceController, PersistenceController)

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	if (managedObjectContext != nil) {
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		managedObjectContext.persistentStoreCoordinator = coordinator;
	}
	return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel != nil) {
		return managedObjectModel;
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"PocketDocket" ofType:@"momd"];
	NSURL *momURL = [NSURL fileURLWithPath:path];
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];    
	return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (persistentStoreCoordinator != nil) {
		return persistentStoreCoordinator;
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"PocketDocket.sqlite"]];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	NSError *error = nil;
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}    
	
	return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Registering Defaults

+ (void)initialize {
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
												  forKey:@"PDFirstLaunch"]];
}

#pragma mark -
#pragma mark Undoing Changes

- (NSUndoManager *)undoManager {
	NSUndoManager* undoManager = [self.managedObjectContext undoManager];
	if (!undoManager) {
		undoManager = [[NSUndoManager alloc] init];
		[self.managedObjectContext setUndoManager:undoManager];
		[undoManager release];
	}
	return undoManager;
}

- (void)beginEdits
{
	[self.undoManager beginUndoGrouping];
}

- (void)saveEdits
{
	[self.undoManager endUndoGrouping];
	[self save];
}

- (void)cancelEdits
{
	[self.undoManager endUndoGrouping];
	[self.undoManager undo];
}

#pragma mark -
#pragma mark Retrieving Model Objects

- (NSFetchedResultsController *)listsFetchedResultsController {
	NSFetchRequest *request = [[self.managedObjectModel fetchRequestTemplateForName:@"allLists"] copy];
	[request autorelease];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	return [[[NSFetchedResultsController alloc] initWithFetchRequest:request
												managedObjectContext:self.managedObjectContext
												  sectionNameKeyPath:nil
														   cacheName:nil] autorelease];
}

- (NSFetchedResultsController *)entriesFetchedResultsControllerForList:(PDList *)list {
	NSDictionary *vars = [NSDictionary dictionaryWithObject:list forKey:@"LIST"];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesForList"
																  substitutionVariables:vars];
	
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
	} else {
		NSLog(@"Error when retrieving lists to increment order, %@, %@", error, [error userInfo]);
	}
	
	return list;
}

- (PDListEntry *)createEntry:(NSString *)text inList:(PDList *)list {
	NSDictionary *vars = [NSDictionary dictionaryWithObject:list forKey:@"LIST"];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesForList"
																  substitutionVariables:vars];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	// Only get the top one. We just want to determine the highest order value.
	[request setFetchLimit:1];
	
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results) {
		PDListEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"ListEntry"
														   inManagedObjectContext:self.managedObjectContext];
		entry.list = list;
		entry.text = text;
		
		if ([results count] == 0) {
			entry.order = [NSNumber numberWithInteger:0];
		} else {
			entry.order = [NSNumber numberWithInteger:[[[results objectAtIndex:0] order] integerValue] + 1];
		}
		
		[self save];
		
		return entry;
	} else {
		NSLog(@"Error loading entries for creating new entry, %@, %@", error, [error userInfo]);
		return nil;
	}
}

- (void)createFirstLaunchData {
	PDSettingsController *settingsController = [PDSettingsController sharedSettingsController];
	if (!settingsController.firstLaunch) {
		return;
	}
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
	NSString *dataFileName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		? @"DOFirstLaunchData"
		: @"PDFirstLaunchData";
#else
	NSString *dataFileName = @"PDFirstLaunchData";
#endif
#endif
	
	NSString *pathToFile = [[NSBundle mainBundle] pathForResource:dataFileName ofType:@"plist"];
	if (!pathToFile) {
		NSLog(@"Could not load first launch data");
		return;
	}
	
	NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:pathToFile];
	PDList *list = [self createList];
	list.title = [dataDict valueForKey:@"title"];
	
	NSArray *entries = [dataDict valueForKey:@"entries"];
	for (NSDictionary *entryDict in entries) {
		PDListEntry *entry = [self createEntry:[entryDict valueForKey:@"text"]
										inList:list];
		NSString *comment = [entryDict valueForKey:@"comment"];
		if (comment) {
			entry.comment = comment;
		}
	}
	
	[self save];
	[settingsController saveSelectedList:list];
	settingsController.firstLaunch = NO;
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

- (void)moveEntry:(PDListEntry *)entry fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow {
	if (fromRow == toRow)
		return;
	
	NSUInteger minRow = MIN(fromRow, toRow);
	NSUInteger maxRow = MAX(fromRow, toRow);
	
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInteger:minRow], @"MIN_ROW",
						  [NSNumber numberWithInteger:maxRow], @"MAX_ROW",
						  entry.list, @"LIST", nil];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesBetween"
																  substitutionVariables:vars];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *records = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (records) {
		NSUInteger index = (minRow == fromRow) ? minRow : minRow + 1;
		for (PDListEntry *each in records) {
			if ([each isEqual:entry]) {
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
	} else {
		NSLog(@"Error retrieving objects with higher order, %@, %@", error, [error userInfo]);
	}
}

- (void)deleteEntry:(PDListEntry *)entry {
	PDList *list = entry.list;
	
	NSNumber *position = entry.order;
	[self.managedObjectContext deleteObject:entry];
	
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:
						  position, @"POSITION", list, @"LIST", nil];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesAbove"
																  substitutionVariables:vars];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results) {
		for (PDListEntry *each in results) {
			each.order = [NSNumber numberWithInteger:[each.order integerValue] - 1];
		}
	} else {
		NSLog(@"Error retrieving objects with higher order, %@, %@", error, [error userInfo]);
	}
	
	// make sure the completion counts update
	[self.managedObjectContext refreshObject:list mergeChanges:YES];
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
	[managedObjectModel release];
	[persistentStoreCoordinator release];
	[super dealloc];
}

@end
