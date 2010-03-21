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

@end
