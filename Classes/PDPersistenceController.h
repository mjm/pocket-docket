@class PDList;
@class PDListEntry;

//! Handles various persistence related operations.
/*!
 \nosubgrouping
 */
@interface PDPersistenceController : NSObject {
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSUndoManager *undoManager;

+ (PDPersistenceController *)sharedPersistenceController;

//! \name Retrieving Model Objects
//@{

//! Creates a fetched results controller for the sorted list of checklists.
/*!
 \return A fetched results controller for lists sorted by order.
 */
- (NSFetchedResultsController *)listsFetchedResultsController;

//! Creates a fetched results controller for the sorted list of entries in a checklist.
/*!
 \param list The checklist whose containing entries should be retrieved.
 \return A fetched results controller for entries sorted by order.
 */
- (NSFetchedResultsController *)entriesFetchedResultsControllerForList:(PDList *)list;

//@}
//! \name Creating Model Objects
//@{

//! Creates a new checklist and adds it to the managed object context.
/*!
 \return A new checklist.
 */
- (PDList *)createList;

//! Creates a new entry with some text and adds it to a list.
/*!
 \param text The text for the new entry.
 \param list The list to add the entry to.
 \return The newly created entry.
 */
- (PDListEntry *)createEntry:(NSString *)text inList:(PDList *)list;

- (void)createFirstLaunchData;

//@}
//! \name Manipulating Model Objects
//@{

//! Changes the position of a list.
/*!
 Makes sure that all lists in between the old and new positions have their order updated
 appropriately.
 
 \param list The list to move.
 \param fromRow The previous location of the list.
 \param toRow The desired location of the list.
 */
- (void)moveList:(PDList *)list fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow;

//! Changes the position of a list entry.
/*!
 Makes sure that all entries in between the old and new positions have their order updated
 appropriately.
 
 \param list The list entry to move.
 \param fromRow The previous location of the list entry.
 \param toRow The desired location of the list entry.
 */
- (void)moveEntry:(PDListEntry *)entry fromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow;

//@}
//! \name Deleting Model Objects
//@{

//! Deletes a checklist.
/*!
 \param list The check list to delete.
 */
- (void)deleteList:(PDList *)list;

//! Deletes an entry from its list.
/*!
 \param entry The entry to delete.
 */
- (void)deleteEntry:(PDListEntry *)entry;

//@}
//! \name Saving Changes
//@{

- (void)save;

//@}

@end
