#import "PDChangeManager.h"

#import "PDPendingChange.h"
#import "ObjectiveResource.h"
#import "ConnectionManager.h"
#import "Categories/NSManagedObject+Additions.h"

NSString *PDChangeTypeCreate = @"create";
NSString *PDChangeTypeUpdate = @"update";
NSString *PDChangeTypeDelete = @"delete";


@interface PDChangeManager ()

@property (nonatomic, retain) NSMutableDictionary *unpublishedCreates;
@property (nonatomic, retain) NSMutableDictionary *unpublishedUpdates;
@property (nonatomic, retain) NSMutableDictionary *unpublishedDeletes;
@property (nonatomic, retain) NSMutableArray *pendingChanges;

- (void)processCreate:(NSManagedObject <PDChanging>*)changed;
- (void)processUpdate:(NSManagedObject <PDChanging>*)changed;
- (void)processDelete:(PDPendingChange *)change;

@end


@implementation PDChangeManager

+ (PDChangeManager *)changeManagerWithContentsOfFile:(NSString *)path
{
	return [[[PDChangeManager alloc] initWithContentsOfFile:path] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)path
{
	if (![super init])
		return nil;
	
	self.path = path;
	
	NSDictionary *changes = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	if (changes)
	{
		self.unpublishedCreates = [[changes objectForKey:PDChangeTypeCreate] mutableCopy];
		self.unpublishedUpdates = [[changes objectForKey:PDChangeTypeUpdate] mutableCopy];
		self.unpublishedDeletes = [[changes objectForKey:PDChangeTypeDelete] mutableCopy];
	}
	else
	{
		self.unpublishedCreates = [NSMutableDictionary dictionary];
		self.unpublishedUpdates = [NSMutableDictionary dictionary];
		self.unpublishedDeletes = [NSMutableDictionary dictionary];
	}
	self.pendingChanges = [NSMutableArray array];
	
	return self;
}

- (void)processCreate:(NSManagedObject <PDChanging> *)changed
{
	id resource = [changed toResource];
	NSError *error = nil;
	if ([resource createRemoteWithResponse:&error])
	{
		changed.remoteIdentifier = [resource getRemoteId];
		NSLog(@"Changed: %@", changed);
		[[changed managedObjectContext] save:&error];
	}
	else
	{
		NSString *idString = [changed objectIDString];
		@synchronized(self)
		{
			[self.unpublishedCreates setObject:[NSDate date] forKey:idString];
		}
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)processUpdate:(NSManagedObject <PDChanging> *)changed
{
	id resource = [changed toResource];
	NSError *error = nil;
	if (![resource updateRemoteWithResponse:&error])
	{
		NSString *idString = [changed objectIDString];
		@synchronized(self)
		{
			if (![self.unpublishedCreates objectForKey:idString])
			{
				[self.unpublishedUpdates setObject:[NSDate date] forKey:idString];
			}
		}
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)processDelete:(PDPendingChange *)change
{
	NSArray *parts = [change.remoteID componentsSeparatedByString:@":"];
	Class resourceClass = NSClassFromString([parts objectAtIndex:0]);
	if (!resourceClass)
	{
		NSLog(@"Could not process delete. Unable to find class named %@.", [parts objectAtIndex:0]);
		return;
	}
	
	id resource = [[resourceClass alloc] init];
	[resource setRemoteId:[parts objectAtIndex:1]];
	
	NSError *error = nil;
	if (![resource destroyRemoteWithResponse:&error])
	{
		@synchronized(self)
		{
			if ([self.unpublishedCreates objectForKey:change.objectID])
			{
				[self.unpublishedCreates removeObjectForKey:change.objectID];
				return;
			}
			
			[self.unpublishedUpdates removeObjectForKey:change.objectID];
			// If we delete something and don't publish it before quitting, we won't be able to find it again
			// So we store the id information for the remote side, since we shouldn't ever be deleting something
			// that doesn't already exist on the remote side.
			[self.unpublishedDeletes setObject:[NSDate date] forKey:change.remoteID];
		}
	}
	
	[resource release];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)addChange:(NSManagedObject <PDChanging> *)changed changeType:(NSString *)changeType
{
	NSLog(@"Adding a pending change of type '%@' for: %@", changeType, changed);
	PDPendingChange *change = [[PDPendingChange alloc] initWithManagedObject:changed changeType:changeType];
	[self.pendingChanges addObject:change];
	[change release];
}

- (void)commitPendingChanges
{
	for (PDPendingChange* change in self.pendingChanges)
	{
		NSLog(@"Committing change of type '%@' for: %@", change.changeType, change.changed);
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		SEL method;
		id argument = change.changed;
		if ([change.changeType isEqualToString:PDChangeTypeCreate])
		{
			method = @selector(processCreate:);
		}
		else if ([change.changeType isEqualToString:PDChangeTypeUpdate])
		{
			method = @selector(processUpdate:);
		}
		else if ([change.changeType isEqualToString:PDChangeTypeDelete])
		{
			method = @selector(processDelete:);
			argument = change;
		}
		
		[[ConnectionManager sharedInstance] runJob:method onTarget:self withArgument:argument];
	}
	
	[self.pendingChanges removeAllObjects];
}

- (void)clearPendingChanges
{
	NSLog(@"Clearing all pending changes");
	[self.pendingChanges removeAllObjects];
}

- (void)saveChanges
{
	NSMutableDictionary *changes = [NSMutableDictionary dictionary];
	[changes setObject:self.unpublishedCreates forKey:PDChangeTypeCreate];
	[changes setObject:self.unpublishedUpdates forKey:PDChangeTypeUpdate];
	[changes setObject:self.unpublishedDeletes forKey:PDChangeTypeDelete];
	
	[NSKeyedArchiver archiveRootObject:changes toFile:self.path];
}

- (void)dealloc
{
	self.path = nil;
	self.unpublishedCreates = nil;
	self.unpublishedUpdates = nil;
	self.unpublishedDeletes = nil;
	self.pendingChanges = nil;
	[super dealloc];
}

@end
