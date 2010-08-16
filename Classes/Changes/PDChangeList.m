#import "PDChangeList.h"

#import "PDChange.h"
#import "PDLocalChange.h"
#import "PDRemoteChange.h"

@interface PDChangeList ()

@property (nonatomic, retain) NSMutableDictionary *changesById;
@property (nonatomic, retain) NSMutableSet *changes;

- (void)mergeChanges;
- (NSArray *)sortedChanges;

@end


@implementation PDChangeList

- (id)init
{
	if (![super init])
		return nil;
	
	self.changes = [NSMutableSet set];
	self.changesById = [NSMutableDictionary dictionary];
	return self;
}


#pragma mark -
#pragma mark Adding Changes

- (void)addChange:(PDChange *)change
{
	changesMerged = NO;
	[self.changes addObject:change];
}

- (void)addPendingChange:(PDPendingChange *)pendingChange date:(NSDate *)date
{
	PDChange *change = [[PDLocalChange alloc] initWithPendingChange:pendingChange date:date];
	[self addChange:change];
	[change release];
}

- (void)addRemoteChange:(Change *)remoteChange
{
	PDChange *change = [[PDRemoteChange alloc] initWithChange:remoteChange];
	[self addChange:change];
	[change release];
}


#pragma mark -
#pragma mark Processing Changes

- (NSArray *)sortedChanges
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *result;
	if ([self.changes respondsToSelector:@selector(sortedArrayUsingDescriptors:)])
	{
		result = [self.changes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	else
	{
		result = [[self.changes allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	[sortDescriptor release];
	
	return result;
}

- (void)mergeChanges
{
	[self.changesById removeAllObjects];
	NSArray *changesCopy = [self sortedChanges];
	
	for (PDChange *change in changesCopy)
	{
		NSString *changeId = change.changeId;
		PDChange *previousChange = [self.changesById objectForKey:changeId];
		
		if (previousChange)
		{
			[self.changes removeObject:previousChange];
			PDChange *chosen = [previousChange changeByMergingWithChange:change];
			if (chosen)
			{
				[self.changes addObject:chosen];
				[self.changesById setObject:chosen forKey:changeId];
			}
		}
		else
		{
			[self.changesById setObject:change forKey:changeId];
		}
	}
	
	changesMerged = YES;
}

- (void)processChangesOnManagedObjectContext:(NSManagedObjectContext *)context
{
	if (!changesMerged)
	{
		[self mergeChanges];
	}
	
	NSLog(@"Processing changes");
	for (PDChange *change in [self sortedChanges])
	{
		NSLog(@"Processing change: %@", change);
		[change executeOnManagedObjectContext:context];
	}
	
	[self.changes removeAllObjects];
	[self.changesById removeAllObjects];
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	self.changes = nil;
	[super dealloc];
}

@end
