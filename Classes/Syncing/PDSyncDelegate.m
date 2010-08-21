#import "PDSyncDelegate.h"

#import "PDCredentials.h"
#import "../Singletons/PDPersistenceController.h"
#import "../Singletons/PDSettingsController.h"
#import "PDList.h"
#import "PDListEntry.h"
#import "../Models/List.h"
#import "../Models/Entry.h"
#import "../Models/Device.h"

#import "ObjectiveResource.h"
#import "ConnectionManager.h"


NSString * const PDCredentialsNeededNotification = @"PDCredentialsNeededNotification";


@interface NSManagedObject (SyncDelegate)
- (void)setOrderValue:(NSInteger)value;
- (NSString *)remoteIdentifier;
@end


@implementation PDSyncDelegate

- (NSManagedObjectContext *)managedObjectContext
{
	return [[PDPersistenceController sharedPersistenceController] managedObjectContext];
}

- (NSManagedObjectModel *)managedObjectModel
{
	return [[PDPersistenceController sharedPersistenceController] managedObjectModel];
}

- (void)createRemoteDevice:(PDSyncController *)syncController
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	Device *device = [[[Device alloc] init] autorelease];
	NSError *error = nil;
	if ([device createRemoteWithResponse:&error])
	{
		[PDSettingsController sharedSettingsController].docketAnywhereDeviceId = device.deviceId;
		[syncController sync];
	}
	else
	{
		NSLog(@"Couldn't create a new device ID: %@, %@", error, [error userInfo]);
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (PDCredentials *)credentialsForSyncController:(PDSyncController *)syncController
{
	NSString *username = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
	if (!username)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PDCredentialsNeededNotification object:self];
		return nil;
	}
	
	NSString *deviceId = [[PDSettingsController sharedSettingsController] docketAnywhereDeviceId];
	if (!deviceId)
	{
		[[ConnectionManager sharedInstance] runJob:@selector(createRemoteDevice:) onTarget:self withArgument:syncController];
		return nil;
	}
	
	NSString *password = [[PDSettingsController sharedSettingsController] docketAnywherePassword];
	
	return [PDCredentials credentialsWithUsername:username password:password deviceId:deviceId];
}

- (void)credentialsNotAuthorizedForSyncController:(PDSyncController *)syncController
{
	// TODO add some info to indicate that the login info is bad.
	[[NSNotificationCenter defaultCenter] postNotificationName:PDCredentialsNeededNotification object:self];
}

- (NSArray *)fetchRequestsForSyncController:(PDSyncController *)syncController
{
	PRINT_SELECTOR
	NSFetchRequest *request = [[self managedObjectModel] fetchRequestFromTemplateWithName:@"allLists"
																	substitutionVariables:[NSDictionary dictionary]];
	
	[request setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease]]];
	return [NSArray arrayWithObject:request];
}

- (NSArray *)remoteInvocationsForSyncController:(PDSyncController *)syncController
{
	PRINT_SELECTOR
	return [NSArray arrayWithObject:[List findAllRemoteInvocation]];
}

- (BOOL)syncController:(PDSyncController *)syncController createRemoteCopyOfLocalObject:(NSManagedObject *)localObject
{
	PRINT_SELECTOR
	if ([localObject isKindOfClass:[PDList class]])
	{
		PDList *localList = (PDList *)localObject;
		List *list = [[[List alloc] init] autorelease];
		list.title = localList.title;
		
		NSError *error = nil;
		if (![list createRemoteWithResponse:&error])
		{
			NSLog(@"Failed to create remote list: %@, %@", error, [error userInfo]);
			return NO;
		}
		
		localList.remoteIdentifier = list.listId;
		
		NSArray *entries = [PDListEntry fetchEntriesForList:[self managedObjectContext] list:localList];
		if (entries)
		{
			for (PDListEntry *localEntry in entries)
			{
				Entry *entry = [[[Entry alloc] init] autorelease];
				entry.text = localEntry.text;
				entry.comment = localEntry.comment;
				entry.checked = localEntry.checked;
				entry.listId = list.listId;
				entry.position = localEntry.order;
				
				NSError *error = nil;
				if (![entry	createRemoteWithResponse:&error])
				{
					NSLog(@"Failed to create remote entry while creating list: %@, %@", error, [error userInfo]);
					return NO;
				}
				
				localEntry.remoteIdentifier = entry.entryId;
			}
		}
		
		return YES;
	}
	else if ([localObject isKindOfClass:[PDListEntry class]])
	{
		PDListEntry *localEntry = (PDListEntry *)localObject;
		Entry *entry = [[[Entry alloc] init] autorelease];
		entry.text = localEntry.text;
		entry.comment = localEntry.comment;
		entry.checked = localEntry.checked;
		entry.listId = localEntry.list.remoteIdentifier;
		
		NSError *error = nil;
		if (![entry createRemoteWithResponse:&error])
		{
			NSLog(@"Failed to create remote entry: %@, %@", error, [error userInfo]);
			return NO;
		}
		
		localEntry.remoteIdentifier = entry.entryId;
		
		return YES;
	}
	else
	{
		NSLog(@"Sync controller gave the delegate something weird: %@", localObject);
		return NO;
	}
}

- (NSManagedObject *)syncController:(PDSyncController *)syncController
	  createLocalCopyOfRemoteObject:(NSObject *)remoteObject
{
	PRINT_SELECTOR
	if ([remoteObject isKindOfClass:[List class]])
	{
		List *list = (List *)remoteObject;
		PDList *localList = [PDList insertInManagedObjectContext:[self managedObjectContext]];
		localList.title = list.title;
		localList.remoteIdentifier = list.listId;
		
		NSError *error = nil;
		NSArray *entries = [Entry findAllRemoteInList:list.listId withResponse:&error];
		if (entries)
		{
			for (Entry *entry in entries)
			{
				PDListEntry *localEntry = [PDListEntry insertInManagedObjectContext:[self managedObjectContext]];
				localEntry.text = entry.text;
				localEntry.comment = entry.comment;
				localEntry.checked = entry.checked;
				localEntry.remoteIdentifier = entry.entryId;
				localEntry.list = localList;
				localEntry.order = entry.position;
			}
			
			// Update the entry counts in the fetched properties
			[[self managedObjectContext] refreshObject:localList mergeChanges:YES];
		}
		else
		{
			NSLog(@"There was a problem fetching remote entries for list with ID %@: %@, %@", list.listId, error, [error userInfo]);
		}
		
		return localList;
	}
	else if ([remoteObject isKindOfClass:[Entry class]])
	{
		Entry *entry = (Entry *)remoteObject;
		PDListEntry *localEntry = [PDListEntry insertInManagedObjectContext:[self managedObjectContext]];
		localEntry.text = entry.text;
		localEntry.comment = entry.comment;
		localEntry.checked = entry.checked;
		localEntry.remoteIdentifier = entry.entryId;
		
		NSArray *lists = [PDList fetchListWithRemoteId:[self managedObjectContext]
											  remoteId:entry.listId];
		NSAssert1(lists && [lists count] > 0, @"There was a problem fetching the list with remote ID %@", entry.listId);
		localEntry.list = [lists objectAtIndex:0];
		
		return localEntry;
	}
	else
	{
		NSLog(@"Sync controller gave the delegate something weird: %@", remoteObject);
		return nil;
	}
}

- (BOOL)syncController:(PDSyncController *)syncController
	deleteRemoteObject:(NSObject *)remoteObject
{
	PRINT_SELECTOR
	NSError *error = nil;
	if (![remoteObject destroyRemoteWithResponse:&error])
	{
		NSLog(@"Failed to delete remote object %@: %@, %@", remoteObject, error, [error userInfo]);
		return NO;
	}
	
	return YES;
}

- (BOOL)syncController:(PDSyncController *)syncController
	 deleteLocalObject:(NSManagedObject *)localObject
{
	PRINT_SELECTOR
	[[self managedObjectContext] deleteObject:localObject];
	return YES;
}

- (void)syncController:(PDSyncController *)syncController mergeEntriesForLocalList:(PDList *)localList remoteList:(List *)list
{
	NSDictionary *subs = [NSDictionary dictionaryWithObject:localList forKey:@"list"];
	NSFetchRequest *request = [[self managedObjectModel] fetchRequestFromTemplateWithName:@"entriesForList"
																	substitutionVariables:subs];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *localObjects = [[self managedObjectContext] executeFetchRequest:request error:&error];
	if (!localObjects)
	{
		NSLog(@"Error fetching local entries to merge: %@, %@", error, [error userInfo]);
		return;
	}
	
	error = nil;
	NSArray *remoteObjects = [Entry findAllRemoteInList:list.listId withResponse:&error];
	if (!remoteObjects)
	{
		NSLog(@"Error fetching remote entries to merge: %@, %@", error, [error userInfo]);
		return;
	}
	
	[syncController mergeLocalObjects:localObjects withRemoteObjects:remoteObjects];
	
	// Update the entry counts in the fetched properties
	[[self managedObjectContext] refreshObject:localList mergeChanges:YES];
}

- (BOOL)syncController:(PDSyncController *)syncController
	 updateLocalObject:(NSManagedObject *)localObject
	  withRemoteObject:(NSObject *)remoteObject
{
	PRINT_SELECTOR
	if ([localObject isKindOfClass:[PDList class]])
	{
		PDList *localList = (PDList *)localObject;
		List *list = (List *)remoteObject;
		
		localList.title = list.title;
		
		[self syncController:syncController mergeEntriesForLocalList:localList remoteList:list];
		
		return YES;
	}
	else if ([localObject isKindOfClass:[PDListEntry class]])
	{
		PDListEntry *localEntry = (PDListEntry *)localObject;
		Entry *entry = (Entry *)remoteObject;
		
		localEntry.text = entry.text;
		localEntry.comment = entry.comment;
		localEntry.checked = entry.checked;
		
		return YES;
	}
	
	NSLog(@"Sync controller gave the delegate something weird: %@, %@", localObject, remoteObject);
	return NO;
}

- (BOOL)syncController:(PDSyncController *)syncController
	updateRemoteObject:(NSObject *)remoteObject
	   withLocalObject:(NSManagedObject *)localObject
{
	PRINT_SELECTOR
	if ([localObject isKindOfClass:[PDList class]])
	{
		PDList *localList = (PDList *)localObject;
		List *list = (List *)remoteObject;
		
		list.title = localList.title;
	}
	else if ([localObject isKindOfClass:[PDListEntry class]])
	{
		PDListEntry *localEntry = (PDListEntry *)localObject;
		Entry *entry = (Entry *)remoteObject;
		
		entry.text = localEntry.text;
		entry.comment = localEntry.comment;
		entry.checked = localEntry.checked;
	}
	else
	{
		NSLog(@"Sync controller gave the delegate something weird: %@, %@", localObject, remoteObject);
		return NO;
	}
	
	NSError *error = nil;
	if (![remoteObject updateRemoteWithResponse:&error])
	{
		NSLog(@"Failed to update remote object %@: %@, %@", remoteObject, error, [error userInfo]);
		return NO;
	}
	
	if ([localObject isKindOfClass:[PDList class]])
	{
		[self syncController:syncController mergeEntriesForLocalList:(PDList *)localObject remoteList:(List *)remoteObject];
	}
	
	return YES;
}

- (BOOL)syncController:(PDSyncController *)syncController movedLocalObject:(NSManagedObject *)localObject
{
	PRINT_SELECTOR
	if ([localObject isKindOfClass:[PDList class]])
	{
		PDList *localList = (PDList *)localObject;
		List *list = [[[List alloc] init] autorelease];
		list.listId = localList.remoteIdentifier;
		
		NSError *error = nil;
		if (![list moveRemoteWithResponse:&error])
		{
			NSLog(@"Failed to move local list on remote side: %@, %@", error, [error userInfo]);
			return NO;
		}
		
		return YES;
	}
	else if ([localObject isKindOfClass:[PDListEntry class]])
	{
		PDListEntry *localEntry = (PDListEntry *)localObject;
		Entry *entry = [[[Entry alloc] init] autorelease];
		entry.entryId = localEntry.remoteIdentifier;
		entry.listId = localEntry.list.remoteIdentifier;
		
		NSError *error = nil;
		if (![entry moveRemoteWithResponse:&error])
		{
			NSLog(@"Failed to move local entry on remote side: %@, %@", error, [error userInfo]);
			return NO;
		}
		
		return YES;
	}
	else
	{
		NSLog(@"Sync controller gave the delegate something weird: %@", localObject);
		return NO;
	}
}

- (BOOL)syncController:(PDSyncController *)syncController movedRemoteObject:(NSObject *)remoteObject
{
	PRINT_SELECTOR
	if (![remoteObject isKindOfClass:[PDResource class]])
	{
		NSLog(@"Sync controller gave the delegate something weird: %@", remoteObject);
		return NO;
	}
	
	PDResource *resource = (PDResource *)remoteObject;
	NSError *error = nil;
	if (![resource gotMoveRemoteWithResponse:&error])
	{
		NSLog(@"Failed to receive movement of remote object %@: %@, %@", resource, error, [error userInfo]);
		return NO;
	}
	
	return YES;
}

- (BOOL)syncController:(PDSyncController *)syncController updateObjectPositions:(NSArray *)localObjects
{
	PRINT_SELECTOR
	if ([localObjects count] == 0)
	{
		// nothing to do, nice and easy
		return YES;
	}
	
	NSMutableArray *remoteIds = [NSMutableArray array];
	
	NSInteger index = 0;
	for (NSManagedObject *object in localObjects)
	{
		[object setOrderValue:index];
		[remoteIds addObject:[object remoteIdentifier]];
		index++;
	}
	
	NSManagedObject *object = [localObjects objectAtIndex:0];
	if ([object isKindOfClass:[PDList class]])
	{
		NSError *error = nil;
		if (![List sortRemote:remoteIds withResponse:&error])
		{
			NSLog(@"Failed to sort remote lists: %@, %@", error, [error userInfo]);
			return NO;
		}
		
		return YES;
	}
	else if ([object isKindOfClass:[PDListEntry class]])
	{
		PDListEntry *entry = (PDListEntry *)object;
		NSString *listId = entry.list.remoteIdentifier;
		
		NSError *error = nil;
		if (![Entry sortRemote:remoteIds forList:listId withResponse:&error])
		{
			NSLog(@"Failed to sort remote entries for list %@: %@, %@", listId, error, [error userInfo]);
			return NO;
		}
		
		return YES;
	}
	else
	{
		NSLog(@"Sync controller gave the delegate something weird: %@", object);
		return NO;
	}
}

@end
