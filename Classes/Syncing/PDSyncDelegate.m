#import "PDSyncDelegate.h"

#import "../Singletons/PDPersistenceController.h"
#import "PDList.h"
#import "PDListEntry.h"
#import "../Models/List.h"
#import "../Models/Entry.h"

#import "ObjectiveResource.h"


@implementation PDSyncDelegate

- (NSManagedObjectContext *)managedObjectContext
{
	return [[PDPersistenceController sharedPersistenceController] managedObjectContext];
}

- (NSManagedObjectModel *)managedObjectModel
{
	return [[PDPersistenceController sharedPersistenceController] managedObjectModel];
}

- (NSArray *)fetchRequestsForSyncController:(PDSyncController *)syncController
{
	NSFetchRequest *request = [[self managedObjectModel] fetchRequestFromTemplateWithName:@"allLists"
																	substitutionVariables:nil];
	
	[request setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease]]];
	return [NSArray arrayWithObject:request];
}

- (NSArray *)remoteInvocationsForSyncController:(PDSyncController *)syncController
{
	return [NSArray arrayWithObject:[List findAllRemoteInvocation]];
}

- (BOOL)syncController:(PDSyncController *)syncController createRemoteCopyOfLocalObject:(NSManagedObject *)localObject
{
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
		
		// TODO create the entries for this list
		
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
	if ([remoteObject isKindOfClass:[List class]])
	{
		List *list = (List *)remoteObject;
		PDList *localList = [PDList insertInManagedObjectContext:[self managedObjectContext]];
		localList.title = list.title;
		localList.remoteIdentifier = list.listId;
		
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
	[[self managedObjectContext] deleteObject:localObject];
	return YES;
}

- (BOOL)syncController:(PDSyncController *)syncController
	 updateLocalObject:(NSManagedObject *)localObject
	  withRemoteObject:(NSObject *)remoteObject
{
	if ([localObject isKindOfClass:[PDList class]])
	{
		PDList *localList = (PDList *)localObject;
		List *list = (List *)remoteObject;
		
		localList.title = list.title;
		
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
	
	return YES;
}

- (BOOL)syncController:(PDSyncController *)syncController movedLocalObject:(NSManagedObject *)localObject
{
	NSLog(@"Updating remote that an object has moved locally.");
	return YES;
}

- (BOOL)syncController:(PDSyncController *)syncController movedRemoteObject:(NSObject *)remoteObject
{
	NSLog(@"Updating remote that an object that was moved remotely has been updated on this device.");
	return YES;
}

@end
