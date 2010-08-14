#import "../Changes/PDChanging.h"
#import "PDChangeManager.h"

@class PDList;
@class PDListEntry;


extern NSString *PDCredentialsNeededNotification;


//! Handles various persistence related operations.
/*!
 \nosubgrouping
 */
@interface PDPersistenceController : NSObject <PDChangeManagerDelegate> {
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;

+ (PDPersistenceController *)sharedPersistenceController;

- (void)beginEdits;
- (void)saveEdits;
- (void)cancelEdits;

- (NSFetchedResultsController *)listsFetchedResultsController;
- (NSFetchedResultsController *)entriesFetchedResultsControllerForList:(PDList *)list;

- (PDList *)createList;
- (PDListEntry *)createEntry:(NSString *)text inList:(PDList *)list;

- (void)createFirstLaunchData;

- (void)moveList:(PDList *)list fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow;
- (void)moveEntry:(PDListEntry *)entry fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow;
- (void)markChanged:(NSManagedObject <PDChanging> *)object;

- (void)deleteList:(PDList *)list;
- (void)deleteEntry:(PDListEntry *)entry;

- (void)save;

@end