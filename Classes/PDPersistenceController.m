#import "PDPersistenceController.h"

#import "SynthesizeSingleton.h"
#import "PDSettingsController.h"
#import "PDCredentials.h"
#import "Models/PDList.h"
#import "Models/PDListEntry.h"

#pragma mark PrivateMethods

@interface PDPersistenceController ()

@property (nonatomic, readonly) NSUndoManager *undoManager;
@property (nonatomic, retain) PDChangeManager *changeManager;
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
	
	NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"PendingChanges.pd"];
	self.changeManager = [PDChangeManager changeManagerWithContentsOfFile:path];
	self.changeManager.delegate = self;
	
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
	
	[self.changeManager clearPendingChanges];
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

- (PDList *)createList
{
	PDList *list = [NSEntityDescription insertNewObjectForEntityForName:@"List"
												 inManagedObjectContext:self.managedObjectContext];
	list.order = [NSNumber numberWithInteger:0];
	[self.changeManager addChange:list changeType:PDChangeTypeCreate];
	
	// Now update the order of all the other lists.
	NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"allLists"];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results)
	{
		for (PDList *each in results)
		{
			if (![each isEqual:list])
			{
				each.order = [NSNumber numberWithInteger:[each.order integerValue] + 1];
			}
		}
	}
	else
	{
		NSLog(@"Error when retrieving lists to increment order, %@, %@", error, [error userInfo]);
	}
	
	return list;
}

- (PDListEntry *)createEntry:(NSString *)text inList:(PDList *)list
{
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
	if (results)
	{
		PDListEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"ListEntry"
														   inManagedObjectContext:self.managedObjectContext];
		entry.list = list;
		entry.text = text;
		
		if ([results count] == 0)
		{
			entry.order = [NSNumber numberWithInteger:0];
		}
		else
		{
			entry.order = [NSNumber numberWithInteger:[[[results objectAtIndex:0] order] integerValue] + 1];
		}
		
		[self.changeManager addChange:entry changeType:PDChangeTypeCreate];
		[self save];
		
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
	PDSettingsController *settingsController = [PDSettingsController sharedSettingsController];
	if (!settingsController.firstLaunch)
	{
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
	[settingsController saveSelectedList:list];
	settingsController.firstLaunch = NO;
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
						  [NSNumber numberWithInteger:minRow], @"MIN_ROW",
						  [NSNumber numberWithInteger:maxRow], @"MAX_ROW", nil];
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
				each.order = [NSNumber numberWithInteger:toRow];
			}
			else
			{
				each.order = [NSNumber numberWithInteger:index];
				index++;
			}
			[self.changeManager addChange:each changeType:PDChangeTypeUpdate];
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
	if (records)
	{
		NSUInteger index = (minRow == fromRow) ? minRow : minRow + 1;
		for (PDListEntry *each in records)
		{
			if ([each isEqual:entry])
			{
				each.order = [NSNumber numberWithInteger:toRow];
			}
			else
			{
				each.order = [NSNumber numberWithInteger:index];
				index++;
			}
			
			[self.changeManager addChange:each changeType:PDChangeTypeUpdate];
		}
		
		[self save];
	}
	else
	{
		NSLog(@"Error retrieving objects to reorder: %@, %@", error, [error userInfo]);
	}
}

- (void)markChanged:(NSManagedObject <PDChanging>*)object
{
	[self.changeManager addChange:object changeType:PDChangeTypeUpdate];
}


#pragma mark -
#pragma mark Deleting Model Objects

- (void)deleteList:(PDList *)list
{
	NSNumber *position = list.order;
	[self.changeManager addChange:list changeType:PDChangeTypeDelete];
	[self.managedObjectContext deleteObject:list];
	
	NSDictionary *vars = [NSDictionary dictionaryWithObject:position forKey:@"POSITION"];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"listsAbove"
																  substitutionVariables:vars];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results)
	{
		for (PDList *each in results)
		{
			each.order = [NSNumber numberWithInteger:[each.order integerValue] - 1];
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
	
	[self.changeManager addChange:entry changeType:PDChangeTypeDelete];
	[self.managedObjectContext deleteObject:entry];
	
	NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:
						  position, @"POSITION", list, @"LIST", nil];
	NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"entriesAbove"
																  substitutionVariables:vars];
	NSError *error;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results)
	{
		for (PDListEntry *each in results)
		{
			each.order = [NSNumber numberWithInteger:[each.order integerValue] - 1];
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
	
	[self.changeManager commitPendingChanges];
}


#pragma mark -
#pragma mark Change Manager Delegate Methods

- (PDCredentials *)credentialsForChangeManager:(PDChangeManager *)changeManager
{
	NSString *username = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
	if (!username)
	{
		// TODO send notification that the credentials are needed.
		return nil;
	}
	
	NSString *password = [[PDSettingsController sharedSettingsController] docketAnywherePassword];
	NSString *deviceId = [[PDSettingsController sharedSettingsController] docketAnywhereDeviceId];
	
	return [PDCredentials credentialsWithUsername:username password:password deviceId:deviceId];
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[managedObjectContext release];
	[managedObjectModel release];
	[persistentStoreCoordinator release];
	[super dealloc];
}

@end
