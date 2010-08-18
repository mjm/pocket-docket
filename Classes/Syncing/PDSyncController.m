#import "PDSyncController.h"

#import "ObjectiveResource.h"
#import "../Categories/NSManagedObjectContext+Additions.h"


#pragma mark Categories

@interface NSManagedObject (SyncingAdditions)
- (NSString *)remoteIdentifier;
- (NSNumber *)moved;
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

- (NSArray *)fetchLocallyChangedObjects;
- (NSArray *)fetchRemotelyChangedObjects;
- (NSSet *)sharedIdsForLocalObjects:(NSArray *)localObjects remoteObjects:(NSArray *)remoteObjects;

- (NSManagedObject *)handleRemotelyCreatedOrLocallyDeletedObject:(NSObject *)remoteObject;
- (BOOL)handleLocallyCreatedOrRemotelyDeletedObject:(NSManagedObject *)localObject;
- (void)reconcileDifferencesBetweenLocalObject:(NSManagedObject *)localObject andRemoteObject:(NSObject *)remoteObject;

@end


#pragma mark -

@implementation PDSyncController


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

- (NSArray *)fetchLocallyChangedObjects
{
	NSMutableArray *changes = [NSMutableArray array];
	NSArray *requests = [self.delegate fetchRequestsForSyncController:self];
	
	for (NSFetchRequest *request in requests)
	{
		NSError *error = nil;
		NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
		
		if (results)
		{
			[changes addObject:results];
		}
		else
		{
			NSLog(@"Error trying to load locally changed objects: %@, %@", error, [error userInfo]);
			return nil;
		}
	}
	
	return changes;
}

- (NSArray *)fetchRemotelyChangedObjects
{
	NSMutableArray *changes = [NSMutableArray array];
	NSArray *invocations = [self.delegate remoteInvocationsForSyncController:self];
	
	for (NSInvocation *invocation in invocations)
	{
		NSArray *results = nil;
		NSError *error = nil;
		NSError **perror = &error;
		
		[invocation setArgument:&perror atIndex:0];
		[invocation invoke];
		[invocation getReturnValue:&results];
		
		if (results)
		{
			[changes addObject:results];
		}
		else
		{
			NSLog(@"Error trying to load remotely changed objects: %@, %@", error, [error userInfo]);
			return nil;
		}
	}
	
	return changes;
}

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
		if (!localObject)
		{
			NSManagedObject *newLocalObject = [self handleRemotelyCreatedOrLocallyDeletedObject:remoteObject];
			if (newLocalObject)
			{
				[results addObject:newLocalObject];
			}
			
			remoteObject = [remoteEnum nextObject];
			continue;
		}
		
		if (!remoteObject)
		{
			if ([self handleLocallyCreatedOrRemotelyDeletedObject:localObject])
			{
				[results addObject:localObject];
			}
			
			localObject = [localEnum nextObject];
			continue;
		}
		
		NSString *localId = [localObject remoteIdentifier];
		NSString *remoteId = [remoteObject getRemoteId];
		
		if (localId && [localId isEqual:remoteId])
		{
			[self reconcileDifferencesBetweenLocalObject:localObject andRemoteObject:remoteObject];
			[results addObject:localObject];
			
			localObject = [localEnum nextObject];
			remoteObject = [remoteEnum nextObject];
			continue;
		}
		
		BOOL localMoved = localId && [updatedIds containsObject:localId];
		BOOL remoteMoved = [updatedIds containsObject:remoteId];
		
		if (localMoved && remoteMoved)
		{
			// TODO handle both changing places
			if ([localObject moved])
			{
				// TODO reconcile changes
				[results addObject:localObject];
			}
			
			if ([remoteObject moved])
			{
				// TODO reconcile changes
				// TODO add local object
			}
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
	}
	
	return results;
}

- (void)sync
{
	NSArray *localChanges = [self fetchLocallyChangedObjects];
	if (!localChanges)
	{
		return;
	}
	
	NSArray *remoteChanges = [self fetchRemotelyChangedObjects];
	if (!remoteChanges)
	{
		return;
	}
	
	if ([localChanges count] == [remoteChanges count])
	{
		NSLog(@"Local and remote change requests don't match.");
		return;
	}
	
	NSEnumerator *localEnum = [localChanges objectEnumerator];
	NSEnumerator *remoteEnum = [remoteChanges objectEnumerator];
	
	NSArray *localChange;
	NSArray *remoteChange;
	while ((localChange = [localEnum nextObject]) && (remoteChange = [remoteEnum nextObject]))
	{
		[self mergeLocalObjects:localChange withRemoteObjects:remoteChange];
	}
}

@end
