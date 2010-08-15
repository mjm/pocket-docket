#import "PDChangeManager.h"

#import "Change.h"
#import "PDCredentials.h"
#import "PDPendingChange.h"
#import "PDChangeList.h"
#import "NSObject+DeviceMethods.h"
#import "ObjectiveResource.h"
#import "ConnectionManager.h"
#import "../Categories/NSManagedObject+Additions.h"
#import "../Categories/NSManagedObjectContext+Additions.h"

// TODO don't require this
#import "../Singletons/PDSettingsController.h"

NSString *PDChangeTypeCreate = @"create";
NSString *PDChangeTypeUpdate = @"update";
NSString *PDChangeTypeDelete = @"delete";


@interface PDChangeManager ()

@property (nonatomic, retain) NSMutableDictionary *unpublishedCreates;
@property (nonatomic, retain) NSMutableDictionary *unpublishedUpdates;
@property (nonatomic, retain) NSMutableDictionary *unpublishedDeletes;
@property (nonatomic, retain) NSMutableArray *pendingChanges;

- (BOOL)processCreate:(NSManagedObject <PDLocalChanging>*)changed;
- (BOOL)processUpdate:(NSManagedObject <PDLocalChanging>*)changed;
- (BOOL)processDelete:(PDPendingChange *)change;

- (void)applyCredentials:(PDCredentials *)credentials;
- (void)clearCredentials;

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

- (BOOL)processCreate:(NSManagedObject <PDLocalChanging> *)changed
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

- (BOOL)processUpdate:(NSManagedObject <PDLocalChanging> *)changed
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

- (void)addChange:(NSManagedObject <PDLocalChanging> *)changed changeType:(NSString *)changeType
{
	NSLog(@"Adding a pending change of type '%@' for: %@", changeType, changed);
	PDPendingChange *change = [[PDPendingChange alloc] initWithManagedObject:changed changeType:changeType];
	[self.pendingChanges addObject:change];
	[change release];
}

- (void)applyCredentials:(PDCredentials *)credentials
{
	[ObjectiveResourceConfig setUser:credentials.username];
	[ObjectiveResourceConfig setPassword:credentials.password];
	[ObjectiveResourceConfig setDeviceId:credentials.deviceId];
}

- (void)clearCredentials
{
	// Clear these out of memory, in the interest of security.
	[ObjectiveResourceConfig setUser:nil];
	[ObjectiveResourceConfig setPassword:nil];
	[ObjectiveResourceConfig setDeviceId:nil];
}

- (BOOL)doPublishChangesWithCredentials:(PDCredentials *)credentials
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self applyCredentials:credentials];
	
	PDChangeList *changeList = [[PDChangeList alloc] init];
	NSError *error = nil;
	NSArray *changes = [Change findAllRemoteWithResponse:&error];
	if (changes)
	{
		NSLog(@"Found changes: %@", changes);
	}
	else
	{
		if ([error code] == 401)
		{
			NSLog(@"Username or password was wrong.");
		}
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		return NO;
	}

	for (Change *change in changes)
	{
		[changeList addRemoteChange:change];
	}
	
	for (NSString *objectIDString in self.unpublishedCreates)
	{
		NSError *error = nil;
		NSManagedObject *object = [self.managedObjectContext existingObjectWithIDString:objectIDString error:&error];
		if (object)
		{
			// TODO clean this up
			
			PDPendingChange *change = [[PDPendingChange alloc] initWithManagedObject:object changeType:PDChangeTypeCreate];
			[changeList addPendingChange:change date:[self.unpublishedCreates objectForKey:objectIDString]];
			[change release];
		}
		else
		{
			NSLog(@"Could not fetch previously created object: %@, %@", error, [error userInfo]);
		}
	}
	
	for (NSString *objectIDString in self.unpublishedUpdates)
	{
		NSError *error = nil;
		NSManagedObject *object = [self.managedObjectContext existingObjectWithIDString:objectIDString error:&error];
		if (object)
		{
			// TODO clean this up
			
			PDPendingChange *change = [[PDPendingChange alloc] initWithManagedObject:object changeType:PDChangeTypeUpdate];
			[changeList addPendingChange:change date:[self.unpublishedUpdates objectForKey:objectIDString]];
			[change release];
		}
		else
		{
			NSLog(@"Could not fetch previously updated object: %@, %@", error, [error userInfo]);
		}
	}
	
	for (NSString *remoteID in self.unpublishedDeletes)
	{
		PDPendingChange *change = [[PDPendingChange alloc] init];
		change.remoteID = remoteID;
		change.changeType = PDChangeTypeDelete;
		[changeList addPendingChange:change date:[self.unpublishedDeletes objectForKey:remoteID]];
		[change release];
	}
	
	[changeList processChangesOnManagedObjectContext:self.managedObjectContext];
	[changeList release];
	
	[self clearCredentials];
	
	[self.unpublishedCreates removeAllObjects];
	[self.unpublishedUpdates removeAllObjects];
	[self.unpublishedDeletes removeAllObjects];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self saveChanges];
	return YES;
}

- (void)doCommitChangesWithCredentials:(PDCredentials *)credentials
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	attemptRemote = credentials != nil;
	
	if (attemptRemote)
	{		
		attemptRemote = [self doPublishChangesWithCredentials:credentials];
		
		[self applyCredentials:credentials];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = attemptRemote;
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
	
	[self clearCredentials];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self.pendingChanges removeAllObjects];
	[self saveChanges];
}

- (void)commitPendingChanges
{
	PDCredentials *credentials = [self.delegate credentialsForChangeManager:self];
	[[ConnectionManager sharedInstance] runJob:@selector(doCommitChangesWithCredentials:)
									  onTarget:self
								  withArgument:credentials];
}

- (void)clearPendingChanges
{
	NSLog(@"Clearing all pending changes");
	[self.pendingChanges removeAllObjects];
}

- (void)refreshAndPublishChanges
{
	PDCredentials *credentials = [self.delegate credentialsForChangeManager:self];
	if (credentials)
	{
		[[ConnectionManager sharedInstance] runJob:@selector(doPublishChangesWithCredentials:)
										  onTarget:self
									  withArgument:credentials];
	}
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
	self.managedObjectContext = nil;
	self.path = nil;
	self.unpublishedCreates = nil;
	self.unpublishedUpdates = nil;
	self.unpublishedDeletes = nil;
	self.pendingChanges = nil;
	[super dealloc];
}

@end
