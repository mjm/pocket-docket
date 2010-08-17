@protocol PDSyncControllerDelegate;


@interface PDSyncController : NSObject

@property (nonatomic, assign) id <PDSyncControllerDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (PDSyncController *)syncControllerWithManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (NSArray *)mergeLocalObjects:(NSArray *)localObjects withRemoteObjects:(NSArray *)remoteObjects;
- (void)sync;

@end


@protocol PDSyncControllerDelegate <NSObject>

- (NSArray *)fetchRequestsForSyncController:(PDSyncController *)syncController;
- (NSArray *)remoteInvocationsForSyncController:(PDSyncController *)syncController;

@end