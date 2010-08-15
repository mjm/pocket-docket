#import "PDLocalChange.h"

#import "PDPendingChange.h"
#import "ObjectiveResource.h"
#import "PDChangeManager.h"


@interface PDLocalChange ()

@property (nonatomic, retain) PDPendingChange *pendingChange;

@end


@implementation PDLocalChange

- (id)initWithPendingChange:(PDPendingChange *)pendingChange date:(NSDate *)date
{
	if (![super initWithType:pendingChange.changeType date:date])
		return nil;
	
	self.pendingChange = pendingChange;
	return self;
}

- (BOOL)isLocal
{
	return YES;
}

- (NSString *)changeId
{
	if (self.pendingChange.remoteID)
	{
		return self.pendingChange.remoteID;
	}
	
	return self.pendingChange.objectID;
}


#pragma mark -
#pragma mark Executing a Change

- (BOOL)processCreate
{
	id resource = [self.pendingChange.changed toResource];
	NSError *error = nil;
	if ([resource createRemoteWithResponse:&error])
	{
		self.pendingChange.changed.remoteIdentifier = [resource getRemoteId];
		[[self.pendingChange.changed managedObjectContext] save:&error];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)processUpdate
{
	id resource = [self.pendingChange.changed toResource];
	NSError *error = nil;
	if ([resource updateRemoteWithResponse:&error])
	{
		return YES;
	}
	
	return NO;
}

- (BOOL)processDelete
{
	NSArray *parts = [self.pendingChange.remoteID componentsSeparatedByString:@":"];
	Class resourceClass = NSClassFromString([parts objectAtIndex:0]);
	if (!resourceClass)
	{
		NSLog(@"Could not process delete. Unable to find class named %@.", [parts objectAtIndex:0]);
		return NO;
	}
	
	id resource = [[[resourceClass alloc] init] autorelease];
	[resource setRemoteId:[parts objectAtIndex:1]];
	
	NSError *error = nil;
	if ([resource destroyRemoteWithResponse:&error])
	{
		return YES;
	}
	
	return NO;
}

- (BOOL)execute
{
	if ([self.changeType isEqualToString:PDChangeTypeCreate])
	{
		return [self processCreate];
	}
	else if ([self.changeType isEqualToString:PDChangeTypeUpdate])
	{
		return [self processUpdate];
	}
	else
	{
		return [self processDelete];
	}
}

- (void)executeOnManagedObjectContext:(NSManagedObjectContext *)context
{
	NSManagedObjectID *objectID = [[context persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:self.pendingChange.objectID]];
	NSError *error = nil;
	self.pendingChange.changed = [context existingObjectWithID:objectID error:&error];
	
	[self execute];
}

@end
