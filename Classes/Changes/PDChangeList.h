@class PDChange;
@class Change;
@class PDPendingChange;

@interface PDChangeList : NSObject
{
	BOOL changesMerged;
}

- (void)addChange:(PDChange *)change;
- (void)addPendingChange:(PDPendingChange *)pendingChange date:(NSDate *)date;
- (void)addRemoteChange:(Change *)remoteChange;

- (void)processChangesOnManagedObjectContext:(NSManagedObjectContext *)context;

@end
