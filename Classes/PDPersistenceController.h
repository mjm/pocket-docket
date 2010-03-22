@class PDList;

//! Handles various persistence related operations.
/*!
 \nosubgrouping
 */
@interface PDPersistenceController : NSObject {
	//! \name Accessing Core Data
	//@{
	
	//! The Core Data managed object context.
	NSManagedObjectContext *managedObjectContext;
	//@}
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//! \name Initializing a Persistence Controller
//@{

//! Creates a new persistence controller with a managed object context.
/*!
 \param context The Core Data managed object context.
 \return A new persistence controller.
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

//@}
//! \name Retrieving Model Objects
//@{

//! Creates a fetched results controller for the sorted list of checklists.
/*!
 \return A fetched results controller for lists sorted by order.
 */
- (NSFetchedResultsController *)listsFetchedResultsController;

//@}
//! \name Creating Model Objects
//@{

//! Creates a new checklist and adds it to the managed object context.
/*!
 \return A new checklist.
 */
- (PDList *)createList;

//@}
//! \name Deleting Model Objects
//@{

//! Deletes a checklist.
/*!
 \param list The check list to delete.
 */
- (void)deleteList:(PDList *)list;

//@}
//! \name Saving Changes
//@{

- (void)save;

//@}

@end
