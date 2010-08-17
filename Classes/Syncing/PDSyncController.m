#import "PDSyncController.h"

#import "ObjectiveResource.h"

@interface PDSyncController ()

- (NSArray *)fetchLocallyChangedObjects;
- (NSArray *)fetchRemotelyChangedObjects;
- (NSSet *)sharedIdsForLocalObjects:(NSArray *)localObjects remoteObjects:(NSArray *)remoteObjects;

- (NSManagedObject *)handleRemotelyCreatedOrLocallyDeletedObject:(NSObject *)remoteObject;
- (BOOL)handleLocallyCreatedOrRemotelyDeletedObject:(NSManagedObject *)localObject;
- (void)reconcileDifferencesBetweenLocalObject:(NSManagedObject *)localObject andRemoteObject:(NSObject *)remoteObject;

@end


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
