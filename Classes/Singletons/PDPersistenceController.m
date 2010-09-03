#import "PDPersistenceController.h"

#import "SynthesizeSingleton.h"
#import "PDSettingsController.h"
#import "PDCredentials.h"
#import "PDList.h"
#import "PDListEntry.h"
#import "../Models/Device.h"
#import "PDSyncController.h"
#import "PDSyncDelegate.h"

#import "ObjectiveResource.h"


#pragma mark Categories

@interface NSManagedObject (SyncMethods)
- (void)setUpdatedSinceSyncValue:(BOOL)value;
@end


#pragma mark Private Methods

@interface PDPersistenceController ()

@property (nonatomic, readonly) NSUndoManager *undoManager;
@property (nonatomic, retain) PDSyncController *syncController;
- (NSString *)applicationDocumentsDirectory;

@end


#pragma mark -

@implementation PDPersistenceController

SYNTHESIZE_SINGLETON_FOR_CLASS(PDPersistenceController, PersistenceController)


#pragma mark -
#pragma mark Initializing a Persistence Controller

- (id)init
{
	if (![super init])
		return nil;
	
	self.syncController = [PDSyncController syncControllerWithManagedObjectContext:self.managedObjectContext];
	self.syncController.delegate = [[PDSyncDelegate alloc] init];
	
	return self;
}


#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
	if (managedObjectContext != nil)
	{
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil)
	{
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		managedObjectContext.persistentStoreCoordinator = coordinator;
	}
	return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
	if (managedObjectModel != nil)
	{
		return managedObjectModel;
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"PocketDocket" ofType:@"momd"];
	NSURL *momURL = [NSURL fileURLWithPath:path];
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];    
	return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator != nil)
	{
		return persistentStoreCoordinator;
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"PocketDocket.sqlite"]];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	NSError *error = nil;
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}    
	
	return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Undoing Changes

- (NSUndoManager *)undoManager
{
	NSUndoManager* undoManager = [self.managedObjectContext undoManager];
	if (!undoManager)
	{
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
	
	//[self.changeManager clearPendingChanges];
}


#pragma mark -
#pragma mark Retrieving Model Objects

- (NSFetchedResultsController *)listsFetchedResultsController
{
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

- (NSFetchedResultsController *)entriesFetchedResultsControllerForList:(PDList *)list
{
	NSDictionary *vars = [NSDictionary dictionaryWithObject:list forKey:@"list"];
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

- (PDList *)createList
{
	PDList *list = [PDList insertInManagedObjectContext:self.managedObjectContext];
	list.orderValue = 0;
	
	// Now update the order of all the other lists.
	NSArray *results = [PDList fetchAllLists:self.managedObjectContext];
	if (results)
	{
		for (PDList *each in results)
		{
			if (![each isEqual:list])
			{
				each.orderValue = each.orderValue + 1;
			}
		}
	}
	
	return list;
}

- (PDListEntry *)createEntry:(NSString *)text inList:(PDList *)list
{
	NSDictionary *vars = [NSDictionary dictionaryWithObject:list forKey:@"list"];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesForList"
																  substitutionVariables:vars];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	// Only get the top one. We just want to determine the highest order value.
	[request setFetchLimit:1];
	
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results)
	{
		PDListEntry *entry = [PDListEntry insertInManagedObjectContext:self.managedObjectContext];
		entry.list = list;
		entry.text = text;
		
		if ([results count] == 0)
		{
			entry.orderValue = 0;
		}
		else
		{
			entry.orderValue = [[results objectAtIndex:0] orderValue] + 1;
		}
		
		return entry;
	}
	else
	{
		NSLog(@"Error loading entries for creating new entry, %@, %@", error, [error userInfo]);
		return nil;
	}
}

- (void)createFirstLaunchData
{	
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
	if (!pathToFile)
	{
		NSLog(@"Could not load first launch data");
		return;
	}
	
	NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:pathToFile];
	PDList *list = [self createList];
	list.title = [dataDict valueForKey:@"title"];
	
	NSArray *entries = [dataDict valueForKey:@"entries"];
	for (NSDictionary *entryDict in entries)
	{
		PDListEntry *entry = [self createEntry:[entryDict valueForKey:@"text"]
										inList:list];
		NSString *comment = [entryDict valueForKey:@"comment"];
		if (comment)
		{
			entry.comment = comment;
		}
	}
	
	[self save];
	[[PDSettingsController sharedSettingsController] saveSelectedList:list];
}


#pragma mark -
#pragma mark Manipulating Model Objects

- (void)moveList:(PDList *)list fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow
{
	if (fromRow == toRow)
		return;
	
	NSUInteger minRow = MIN(fromRow, toRow);
	NSUInteger maxRow = MAX(fromRow, toRow);
	
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInteger:minRow], @"minRow",
						  [NSNumber numberWithInteger:maxRow], @"maxRow", nil];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"listsBetween"
																  substitutionVariables:vars];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *records = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (records)
	{
		NSUInteger index = (minRow == fromRow) ? minRow : minRow + 1;
		for (PDList *each in records)
		{
			if ([each isEqual:list])
			{
				each.orderValue = toRow;
			}
			else
			{
				each.orderValue = index;
				index++;
			}
			each.movedSinceSyncValue = YES;
		}
		
		[self save];
	}
	else
	{
		NSLog(@"Error retrieving objects to reorder: %@, %@", error, [error userInfo]);
	}
}

- (void)moveEntry:(PDListEntry *)entry fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow
{
	if (fromRow == toRow)
		return;
	
	NSUInteger minRow = MIN(fromRow, toRow);
	NSUInteger maxRow = MAX(fromRow, toRow);
	
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInteger:minRow], @"minRow",
						  [NSNumber numberWithInteger:maxRow], @"maxRow",
						  entry.list, @"list", nil];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesBetween"
																  substitutionVariables:vars];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *records = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (records)
	{
		NSUInteger index = (minRow == fromRow) ? minRow : minRow + 1;
		for (PDListEntry *each in records)
		{
			if ([each isEqual:entry])
			{
				each.orderValue = toRow;
			}
			else
			{
				each.orderValue = index;
				index++;
			}
			each.movedSinceSyncValue = YES;
		}
		
		[self save];
	}
	else
	{
		NSLog(@"Error retrieving objects to reorder: %@, %@", error, [error userInfo]);
	}
}

- (void)markChanged:(NSManagedObject *)object
{
	[object setUpdatedSinceSyncValue:YES];
}


#pragma mark -
#pragma mark Deleting Model Objects

- (void)deleteList:(PDList *)list
{
	NSNumber *position = list.order;
	list.deletedAt = [NSDate date];
	
	NSDictionary *vars = [NSDictionary dictionaryWithObject:position forKey:@"position"];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"listsAbove"
																  substitutionVariables:vars];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results)
	{
		for (PDList *each in results)
		{
			each.orderValue = each.orderValue - 1;
		}
	}
	else
	{
		NSLog(@"Error retrieving objects with higher order, %@, %@", error, [error userInfo]);
	}
}

- (void)deleteEntry:(PDListEntry *)entry
{
	PDList *list = entry.list;
	
	NSNumber *position = entry.order;
	entry.deletedAt = [NSDate date];
	
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:
						  position, @"position", list, @"list", nil];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesAbove"
																  substitutionVariables:vars];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results)
	{
		for (PDListEntry *each in results)
		{
			each.orderValue = each.orderValue - 1;
		}
	}
	else
	{
		NSLog(@"Error retrieving objects with higher order, %@, %@", error, [error userInfo]);
	}
	
	// make sure the completion counts update
	[self.managedObjectContext refreshObject:list mergeChanges:YES];
}


#pragma mark -
#pragma mark Saving Changes

- (void)save
{
	NSError *error;
	
	if (![self.managedObjectContext save:&error])
	{
		NSLog(@"Error saving changes: %@, %@", error, [error userInfo]);
	}
	
	[self.syncController sync];
}

- (void)refresh
{
	NSString *username = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
	if (!username)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PDCredentialsNeededNotification object:self];
		return;
	}
	
	[self save];
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	self.syncController = nil;
	[managedObjectContext release];
	[managedObjectModel release];
	[persistentStoreCoordinator release];
	[super dealloc];
}

@end
