#import "PDSyncController.h"

#import "NSObject+DeviceMethods.h"
#import "ObjectiveResource.h"
#import "ObjectiveResourceConfig.h"
#import "ConnectionManager.h"
#import "../Categories/NSManagedObjectContext+Additions.h"
#import "PDCredentials.h"


#pragma mark Categories

@interface NSManagedObject (SyncingAdditions)
- (NSString *)remoteIdentifier;
- (BOOL)movedSinceSyncValue;
- (void)setMovedSinceSyncValue:(BOOL)value;
- (NSDate *)updatedAt;
@end

@interface NSObject (SyncingAdditions)
- (NSString *)entityName;
- (NSNumber *)moved;
- (NSDate *)updatedAt;
@end


#pragma mark -
#pragma mark Private Methods

@interface PDSyncController ()

- (NSSet *)sharedIdsForLocalObjects:(NSArray *)localObjects remoteObjects:(NSArray *)remoteObjects;

- (NSManagedObject *)handleRemotelyCreatedOrLocallyDeletedObject:(NSObject *)remoteObject;
- (BOOL)handleLocallyCreatedOrRemotelyDeletedObject:(NSManagedObject *)localObject;
- (void)reconcileDifferencesBetweenLocalObject:(NSManagedObject *)localObject andRemoteObject:(NSObject *)remoteObject;

- (NSObject *)remoteObjectInArray:(NSArray *)objects matchingLocalObject:(NSManagedObject *)localObject;
- (NSManagedObject *)localObjectMatchingRemoteObject:(NSObject *)remoteObject;

- (void)syncStarted;
- (void)syncStopped;

@end


#pragma mark -
#pragma mark Notifications

NSString * const PDSyncDidStartNotification = @"PDSyncDidStartNotification";
NSString * const PDSyncDidStopNotification = @"PDSyncDidStopNotification";


#pragma mark -

@implementation PDSyncController


#pragma mark -
#pragma mark Creating a Sync Controller

+ (PDSyncController *)syncControllerWithManagedObjectContext:(NSManagedObjectContext *)context
{
	return [[[self alloc] initWithManagedObjectContext:context] autorelease];
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
	if (![super init])
		return nil;
	
	self.managedObjectContext = context;
	return self;
}


#pragma mark -
#pragma mark Private Syncing Methods

- (NSSet *)sharedIdsForLocalObjects:(NSArray *)localObjects remoteObjects:(NSArray *)remoteObjects
{
	// Find local IDs.
	NSMutableSet *updatedIds = [NSMutableSet set];
	for (id local in localObjects)
	{
		if ([local remoteIdentifier])
		{
			[updatedIds addObject:[local remoteIdentifier]];
		}
	}
	
	// Find remote IDs.
	NSMutableSet *remoteIds = [NSMutableSet set];
	for (NSObject *remote in remoteObjects)
	{
		[remoteIds addObject:[remote getRemoteId]];
	}
	
	// Only keep items present in both sets.
	[updatedIds intersectSet:remoteIds];
	return updatedIds;
}

- (NSManagedObject *)handleRemotelyCreatedOrLocallyDeletedObject:(NSObject *)remoteObject
{
	PRINT_SELECTOR
	// Need to determine why it's on the remote side and not the local side (create vs. delete)
	NSManagedObjectModel *mom = self.managedObjectContext.managedObjectModel;
	NSString *entityName = [remoteObject entityName];
	
	NSEntityDescription *entity = [[mom entitiesByName] objectForKey:entityName];
	if (!entity)
	{
		NSLog(@"Couldn't load remote object entity with name: %@", entityName);
		return nil;
	}
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	[request setFetchLimit:1];
	[request setPredicate:[NSPredicate predicateWithFormat:@"remoteIdentifier = %@ AND deletedAt != nil", [remoteObject getRemoteId]]];
	
	NSError *error = nil;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (results)
	{
		if ([results count] > 0)
		{
			// We found a deleted copy, so this item was deleted locally
			if (![self.delegate syncController:self deleteRemoteObject:remoteObject])
			{
				NSLog(@"Sync controller delegate failed to delete remote copy of object: %@", remoteObject);
			}
			return nil;
		}
		else
		{
			// No deleted copy, so this item was created remotely
			NSManagedObject *created = [self.delegate syncController:self createLocalCopyOfRemoteObject:remoteObject];
			if (!created)
			{
				NSLog(@"Sync controller delegate failed to create local copy of object: %@", remoteObject);
			}
			return created;
		}
	}
	else
	{
		NSLog(@"Couldn't check if remote object with ID %@ has been deleted: %@, %@", [remoteObject getRemoteId], error, [error userInfo]);
		return nil;
	}
}

- (BOOL)handleLocallyCreatedOrRemotelyDeletedObject:(NSManagedObject *)localObject
{
	PRINT_SELECTOR
	NSString *remoteId = [localObject remoteIdentifier];
	BOOL result;
	
	if (remoteId)
	{
		// If it has a remote ID, than it was already created on the remote side at some point.
		// In that case, it's gone because the remote side deleted it.
		result = [self.delegate syncController:self deleteLocalObject:localObject];
		if (!result)
		{
			NSLog(@"Sync controller delegate failed to delete local copy of object: %@", localObject);
		}
	}
	else
	{
		// If it has no remote ID, then it is not present on the remote side because it hasn't been
		// created there.
		result = [self.delegate syncController:self createRemoteCopyOfLocalObject:localObject];
		if (!result)
		{
			NSLog(@"Sync controller delegate failed to create remote copy of object: %@", localObject);
		}
	}
	
	return result;
}

- (void)reconcileDifferencesBetweenLocalObject:(NSManagedObject *)localObject
							   andRemoteObject:(NSObject *)remoteObject
{
	PRINT_SELECTOR
	BOOL result = NO;
	
	switch ([[localObject updatedAt] compare:[remoteObject updatedAt]])
	{
		case NSOrderedSame:
		case NSOrderedAscending:
			result = [self.delegate syncController:self updateLocalObject:localObject withRemoteObject:remoteObject];
			break;
		case NSOrderedDescending:
			result = [self.delegate syncController:self updateRemoteObject:remoteObject withLocalObject:localObject];
			break;
	}
	
	if (!result)
	{
		NSLog(@"Sync controller delegate failed to update objects: %@, %@", localObject, remoteObject);
	}
}

- (NSObject *)remoteObjectInArray:(NSArray *)objects matchingLocalObject:(NSManagedObject *)localObject
{
	PRINT_SELECTOR
	NSString *remoteId = [localObject remoteIdentifier];
	
	for (NSObject *object in objects)
	{
		if ([[object getRemoteId] isEqualToString:remoteId])
		{
			return object;
		}
	}
	
	NSAssert1(NO, @"Couldn't find remote object with ID %@. This shouldn't happen.", remoteId);
	return nil;
}

- (NSManagedObject *)localObjectMatchingRemoteObject:(NSObject *)remoteObject
{
	PRINT_SELECTOR
	NSString *remoteId = [remoteObject getRemoteId];
	NSString *entityName = [remoteObject entityName];
	
	NSEntityDescription *entity = [[self.managedObjectContext.managedObjectModel entitiesByName] objectForKey:entityName];
	if (!entity)
	{
		return nil;
	}
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"remoteIdentifier = %@", remoteId]];
	[request setFetchLimit:1];
	
	NSError *error = nil;
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (results)
	{
		NSAssert1([results count] > 0, @"Couldn't find local object with remote ID %@. This shouldn't happen.", remoteId);
		return [results objectAtIndex:0];
	}
	else
	{
		NSLog(@"Couldn't retrieve local object with remote ID %@. Error: %@, %@", remoteId, error, [error userInfo]);
		return nil;
	}
}

- (void)syncStarted
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PDSyncDidStartNotification object:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)syncStopped
{
	[ObjectiveResourceConfig setUser:nil];
	[ObjectiveResourceConfig setPassword:nil];
	[ObjectiveResourceConfig setDeviceId:nil];
	
	currentlySyncing = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PDSyncDidStopNotification object:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark -
#pragma mark Syncing

- (NSArray *)mergeLocalObjects:(NSArray *)localObjects withRemoteObjects:(NSArray *)remoteObjects
{
	NSSet *updatedIds = [self sharedIdsForLocalObjects:localObjects remoteObjects:remoteObjects];
	NSMutableArray *results = [NSMutableArray array];

	NSEnumerator *localEnum = [localObjects objectEnumerator];
	NSEnumerator *remoteEnum = [remoteObjects objectEnumerator];
	
	NSManagedObject *localObject = [localEnum nextObject];
	NSObject *remoteObject = [remoteEnum nextObject];
	while (localObject || remoteObject)
	{
		NSLog(@"ITERATION\nLocal Object: %@\nRemote Object: %@", localObject, remoteObject);
		if (!localObject)
		{
			NSManagedObject *newLocalObject = [self handleRemotelyCreatedOrLocallyDeletedObject:remoteObject];
			if (newLocalObject)
			{
				[results addObject:newLocalObject];
			}
			
			remoteObject = [remoteEnum nextObject];
			
			NSLog(@"--- Results so far: %@", results);
			continue;
		}
		
		if (!remoteObject)
		{
			if ([self handleLocallyCreatedOrRemotelyDeletedObject:localObject])
			{
				[results addObject:localObject];
			}
			
			localObject = [localEnum nextObject];
			
			NSLog(@"--- Results so far: %@", results);
			continue;
		}
		
		NSString *localId = [localObject remoteIdentifier];
		NSString *remoteId = [remoteObject getRemoteId];
		
		if (localId && [localId isEqual:remoteId])
		{
			// TODO handle movements to make sure those are ok
			
			[self reconcileDifferencesBetweenLocalObject:localObject andRemoteObject:remoteObject];
			[results addObject:localObject];
			
			localObject = [localEnum nextObject];
			remoteObject = [remoteEnum nextObject];
			
			NSLog(@"--- Results so far: %@", results);
			continue;
		}
		
		BOOL localMoved = localId && [updatedIds containsObject:localId];
		BOOL remoteMoved = [updatedIds containsObject:remoteId];
		
		if (localMoved && remoteMoved)
		{
			if ([localObject movedSinceSyncValue])
			{
				NSObject *myRemoteObject = [self remoteObjectInArray:remoteObjects matchingLocalObject:localObject];
				[self.delegate syncController:self movedLocalObject:localObject];
				[localObject setMovedSinceSyncValue:NO];
				[self reconcileDifferencesBetweenLocalObject:localObject andRemoteObject:myRemoteObject];
				[results addObject:localObject];
			}
			
			localObject = [localEnum nextObject];
			
			if ([[remoteObject moved] boolValue])
			{
				[self.delegate syncController:self movedRemoteObject:remoteObject];
				NSManagedObject *myLocalObject = [self localObjectMatchingRemoteObject:remoteObject];
				[self reconcileDifferencesBetweenLocalObject:myLocalObject andRemoteObject:remoteObject];
				[results addObject:myLocalObject];
			}
			
			remoteObject = [remoteEnum nextObject];
			
			NSLog(@"--- Results so far: %@", results);
			continue;
		}
		
		if (!localMoved)
		{
			if ([self handleLocallyCreatedOrRemotelyDeletedObject:localObject])
			{
				[results addObject:localObject];
			}
			
			localObject = [localEnum nextObject];
		}
		if (!remoteMoved)
		{
			NSManagedObject *newLocalObject = [self handleRemotelyCreatedOrLocallyDeletedObject:remoteObject];
			if (newLocalObject)
			{
				[results addObject:newLocalObject];
			}
			
			remoteObject = [remoteEnum nextObject];
		}
		
		NSLog(@"--- Results so far: %@", results);
	}
	
	[self.delegate syncController:self updateObjectPositions:results];
	
	return results;
}

- (void)doSyncWithCredentials:(PDCredentials *)credentials
{
	[ObjectiveResourceConfig setUser:credentials.username];
	[ObjectiveResourceConfig setPassword:credentials.password];
	[ObjectiveResourceConfig setDeviceId:credentials.deviceId];
	
	NSArray *fetchRequests = [self.delegate fetchRequestsForSyncController:self];
	if (!fetchRequests)
	{
		currentlySyncing = NO;
		return;
	}
	
	NSArray *remoteInvocations = [self.delegate remoteInvocationsForSyncController:self];
	if (!remoteInvocations)
	{
		currentlySyncing = NO;
		return;
	}
	
	NSAssert([fetchRequests count] == [remoteInvocations count], @"Local and remote change requests don't match.");
	
	[self performSelectorOnMainThread:@selector(syncStarted) withObject:nil waitUntilDone:YES];
	
	NSEnumerator *localEnum = [fetchRequests objectEnumerator];
	NSEnumerator *remoteEnum = [remoteInvocations objectEnumerator];
	
	NSFetchRequest *fetchRequest;
	NSInvocation *invocation;
	while ((fetchRequest = [localEnum nextObject]) && (invocation = [remoteEnum nextObject]))
	{
		NSError *error = nil;
		NSArray *localChange = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (!localChange)
		{
			NSLog(@"An error occurred fetching local changes: %@, %@", error, [error userInfo]);
			[self performSelectorOnMainThread:@selector(syncStopped) withObject:nil waitUntilDone:YES];
			return;
		}
		
		NSArray	*remoteChange = nil;
		[invocation invoke];
		[invocation getReturnValue:&remoteChange];
		
		if (!remoteChange)
		{
			NSLog(@"An error occurred fetching remote changes.");
			[self performSelectorOnMainThread:@selector(syncStopped) withObject:nil waitUntilDone:YES];
			return;
		}
		
		[self mergeLocalObjects:localChange withRemoteObjects:remoteChange];
	}
	
	[self performSelectorOnMainThread:@selector(syncStopped) withObject:nil waitUntilDone:YES];
}

- (void)sync
{
	if (currentlySyncing)
	{
		return;
	}
	
	currentlySyncing = YES;
	
	PDCredentials *credentials = [self.delegate credentialsForSyncController:self];
	if (!credentials)
	{
		currentlySyncing = NO;
		return;
	}
	
	[[ConnectionManager sharedInstance] runJob:@selector(doSyncWithCredentials:) onTarget:self withArgument:credentials];
}

@end
