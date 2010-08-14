#import "PDChangeManager.h"

#import "PDCredentials.h"
#import "PDPendingChange.h"
#import "ObjectiveResource.h"
#import "ConnectionManager.h"
#import "../Categories/NSManagedObject+Additions.h"

NSString *PDChangeTypeCreate = @"create";
NSString *PDChangeTypeUpdate = @"update";
NSString *PDChangeTypeDelete = @"delete";


@interface PDChangeManager ()

@property (nonatomic, retain) NSMutableDictionary *unpublishedCreates;
@property (nonatomic, retain) NSMutableDictionary *unpublishedUpdates;
@property (nonatomic, retain) NSMutableDictionary *unpublishedDeletes;
@property (nonatomic, retain) NSMutableArray *pendingChanges;

- (BOOL)processCreate:(NSManagedObject <PDChanging>*)changed;
- (BOOL)processUpdate:(NSManagedObject <PDChanging>*)changed;
- (BOOL)processDelete:(PDPendingChange *)change;

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

- (BOOL)processCreate:(NSManagedObject <PDChanging> *)changed
{
	if (attemptRemote)
	{
		id resource = [changed toResource];
		NSError *error = nil;
		if ([resource createRemoteWithResponse:&error])
		{
			changed.remoteIdentifier = [resource getRemoteId];
			[[changed managedObjectContext] save:&error];
			
			return YES;
		}
	}
	
	NSString *idString = [changed objectIDString];
	@synchronized(self)
	{
		[self.unpublishedCreates setObject:[NSDate date] forKey:idString];
	}
	
	return NO;
}

- (BOOL)processUpdate:(NSManagedObject <PDChanging> *)changed
{
	if (attemptRemote)
	{
		id resource = [changed toResource];
		NSError *error = nil;
		if ([resource updateRemoteWithResponse:&error])
		{
			return YES;
		}
	}

	NSString *idString = [changed objectIDString];
	@synchronized(self)
	{
		if (![self.unpublishedCreates objectForKey:idString])
		{
			[self.unpublishedUpdates setObject:[NSDate date] forKey:idString];
		}
	}
	
	return NO;
}

- (BOOL)processDelete:(PDPendingChange *)change
{
	if (attemptRemote)
	{
		NSArray *parts = [change.remoteID componentsSeparatedByString:@":"];
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
	}
	
	@synchronized(self)
	{
		if ([self.unpublishedCreates objectForKey:change.objectID])
		{
			[self.unpublishedCreates removeObjectForKey:change.objectID];
			return NO;
		}
		
		[self.unpublishedUpdates removeObjectForKey:change.objectID];
		// If we delete something and don't publish it before quitting, we won't be able to find it again
		// So we store the id information for the remote side, since we shouldn't ever be deleting something
		// that doesn't already exist on the remote side.
		[self.unpublishedDeletes setObject:[NSDate date] forKey:change.remoteID];
	}
	
	return NO;
}

- (void)addChange:(NSManagedObject <PDChanging> *)changed changeType:(NSString *)changeType
{
	NSLog(@"Adding a pending change of type '%@' for: %@", changeType, changed);
	PDPendingChange *change = [[PDPendingChange alloc] initWithManagedObject:changed changeType:changeType];
	[self.pendingChanges addObject:change];
	[change release];
}

- (void)doCommitChangesWithCredentials:(PDCredentials *)credentials
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	attemptRemote = credentials != nil;
	
	if (attemptRemote)
	{
		[ObjectiveResourceConfig setUser:credentials.username];
		[ObjectiveResourceConfig setPassword:credentials.password];
		// TODO set device id
		
		// TODO process unpublished changes
	}

	for (PDPendingChange* change in self.pendingChanges)
	{
		NSLog(@"Committing change of type '%@' for: %@", change.changeType, change.changed);

		BOOL result;
		if ([change.changeType isEqualToString:PDChangeTypeCreate])
		{
			result = [self processCreate:change.changed];
		}
		else if ([change.changeType isEqualToString:PDChangeTypeUpdate])
		{
			result = [self processUpdate:change.changed];
		}
		else if ([change.changeType isEqualToString:PDChangeTypeDelete])
		{
			result = [self processDelete:change];
		}
		
		// TODO decide whether to attempt remote connections
	}
	
	// Clear these out of memory, in the interest of security.
	[ObjectiveResourceConfig setUser:nil];
	[ObjectiveResourceConfig setPassword:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self.pendingChanges removeAllObjects];	
}

- (void)commitPendingChanges
{
	PDCredentials *credentials = [self.delegate credentialsForChangeManager:self];
	[[ConnectionManager sharedInstance] runJob:@selector(doCommitChangesWithCredentials:) onTarget:self withArgument:credentials];
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
