@class PDCredentials;

@protocol PDSyncControllerDelegate;


extern NSString * const PDSyncDidStartNotification;
extern NSString * const PDSyncDidStopNotification;

@interface PDSyncController : NSObject
{
	BOOL currentlySyncing;
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	UIBackgroundTaskIdentifier backgroundTask;
#endif
#endif
}

@property (nonatomic, assign) id <PDSyncControllerDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (PDSyncController *)syncControllerWithManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (NSArray *)mergeLocalObjects:(NSArray *)localObjects withRemoteObjects:(NSArray *)remoteObjects;
- (void)sync;

@end


@protocol PDSyncControllerDelegate <NSObject>

- (PDCredentials *)credentialsForSyncController:(PDSyncController *)syncController;
- (NSArray *)fetchRequestsForSyncController:(PDSyncController *)syncController;
- (NSArray *)remoteInvocationsForSyncController:(PDSyncController *)syncController;

- (BOOL)syncController:(PDSyncController *)syncController createRemoteCopyOfLocalObject:(NSManagedObject *)localObject;
- (NSManagedObject *)syncController:(PDSyncController *)syncController
	  createLocalCopyOfRemoteObject:(NSObject *)remoteObject;

- (BOOL)syncController:(PDSyncController *)syncController
	deleteRemoteObject:(NSObject *)remoteObject;
- (BOOL)syncController:(PDSyncController *)syncController
	 deleteLocalObject:(NSManagedObject *)localObject;

- (BOOL)syncController:(PDSyncController *)syncController
	 updateLocalObject:(NSManagedObject *)localObject
	  withRemoteObject:(NSObject *)remoteObject;
- (BOOL)syncController:(PDSyncController *)syncController
	updateRemoteObject:(NSObject *)remoteObject
	   withLocalObject:(NSManagedObject *)localObject;

- (BOOL)syncController:(PDSyncController *)syncController movedLocalObject:(NSManagedObject *)localObject;
- (BOOL)syncController:(PDSyncController *)syncController movedRemoteObject:(NSObject *)remoteObject;
- (BOOL)syncController:(PDSyncController *)syncController updateObjectPositions:(NSArray *)localObjects;

@end