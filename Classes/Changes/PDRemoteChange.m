#import "PDRemoteChange.h"

#import "PDChangeManager.h"
#import "../Models/Change.h"
#import "../Categories/NSManagedObjectContext+Additions.h"


@interface PDRemoteChange ()

@property (nonatomic, retain) Change *change;

- (NSManagedObject *)findEntity:(NSEntityDescription *)entity
				   withRemoteId:(NSString *)remoteId
					  inContext:(NSManagedObjectContext *)ctx;

- (id <PDRemoteChanging>)findRemoteResource;

@end


@implementation PDRemoteChange

- (id)initWithChange:(Change *)remoteChange
{
	if (![super initWithType:remoteChange.event date:remoteChange.createdAt])
		return nil;
	
	self.change = remoteChange;
	return self;
}

- (BOOL)isLocal
{
	return NO;
}

- (NSString *)changeId
{
	return [NSString stringWithFormat:@"%@:%@", self.change.model, self.change.modelId];
}


#pragma mark -
#pragma mark Executing a Change

- (NSManagedObject *)findEntity:(NSEntityDescription *)entity withRemoteId:(NSString *)remoteId inContext:(NSManagedObjectContext *)ctx
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"remoteIdentifier = %@", remoteId]];
	[request setFetchLimit:1];
	
	NSError *error = nil;
	NSArray *results = [ctx executeFetchRequest:request error:&error];
	if (results && [results count] > 0)
	{
		return [results objectAtIndex:0];
	}
	else
	{
		NSLog(@"There was an error fetching the appropriate entity: %@, %@", error, [error userInfo]);
		return nil;
	}
}

- (id <PDRemoteChanging>)findRemoteResource
{
	Class <PDRemoteChanging> resourceClass = [self.change resourceClass];
	
	NSError *error = nil;
	id <PDRemoteChanging> resource = [resourceClass findRemote:self.change.modelId withResponse:&error];
	
	if (resource)
	{
		return resource;
	}
	else
	{
		NSLog(@"An error occurred while trying to fetch the remote object data: %@, %@", error, [error userInfo]);
		return nil;
	}
}

- (void)executeOnManagedObjectContext:(NSManagedObjectContext *)context
{
	NSLog(@"Executing remote change");
	Class <PDRemoteChanging> resourceClass = [self.change resourceClass];
	if (!resourceClass)
	{
		return;
	}
	
	NSString *entityName = [resourceClass entityName];
	if (!entityName)
	{
		return;
	}
	
	NSEntityDescription *entity = [[context.managedObjectModel entitiesByName] objectForKey:entityName];
	
	if ([self.changeType isEqualToString:PDChangeTypeCreate])
	{
		id <PDRemoteChanging> resource = [self findRemoteResource];
		if (resource)
		{
			NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity
											   insertIntoManagedObjectContext:context];
			[resource copyPropertiesTo:object];
		}
	}
	else if ([self.changeType isEqualToString:PDChangeTypeUpdate])
	{
		id <PDRemoteChanging> resource = [self findRemoteResource];
		if (resource)
		{
			NSManagedObject *object = [self findEntity:entity withRemoteId:self.change.modelId inContext:context];
			if (object)
			{
				[resource copyPropertiesTo:object];
			}
		}
	}
	else
	{
		NSManagedObject *object = [self findEntity:entity withRemoteId:self.change.modelId inContext:context];
		if (object)
		{
			[context deleteObject:object];
		}
	}
}

@end
