@class PDPersistenceController;

//! A view controller that displays all of the users lists.
/*!
 
 Allows the user to drill-down into a specific list, remove lists, or create new lists.
 
 \nosubgrouping
 */
@interface PDListsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	//! \name Managing Persistence
	//@{
	
	//! The controller used for persistence operations.
	PDPersistenceController *persistenceController;
	
	//@}
	//! \name Outlets
	//@{
	
	IBOutlet UITableView *table;
	
	IBOutlet UIBarButtonItem *editButton;
	IBOutlet UIBarButtonItem *doneButton;
	IBOutlet UIBarButtonItem *addButton;
	
	//@}
}

@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;

//! \name Initializing a View Controller
//@{

//! Creates a new view controller with a controller to use for persistence.
/*!
 \param controller The controller to use for persistence operations.
 \return A new view controller.
 */
- (id)initWithPersistenceController:(PDPersistenceController *)controller;

//@}
//! \name Actions
//@{

//! Action called when the user wants to edit their lists.
- (IBAction)editLists;

//! Action called when the user is done editing their lists.
- (IBAction)doneEditingLists;

//@}

@end
