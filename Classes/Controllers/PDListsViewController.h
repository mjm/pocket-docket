#import "PDEditListViewController.h"

@class PDPersistenceController;

//! A view controller that displays all of the users lists.
/*!
 
 Allows the user to drill-down into a specific list, remove lists, or create new lists.
 
 \nosubgrouping
 */
@interface PDListsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PDEditListViewControllerDelegate, NSFetchedResultsControllerDelegate> {
	//! \name Managing Persistence
	//@{
	
	//! The controller used for persistence operations.
	PDPersistenceController *persistenceController;
	
	//! The controller used to manage the lists.
	NSFetchedResultsController *fetchedResultsController;
	
	//@}
	//! \name Outlets
	//@{
	
	IBOutlet UITableView *table;

	IBOutlet UIBarButtonItem *addButton;
	IBOutlet UIBarButtonItem *backButton;
	
	//@}
	//! \name Handling State
	//@{
	
	BOOL isAdd;
	BOOL userIsMoving;
	
	//@}
}

@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;

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

//! Action called when the user wants to create a new list.
- (IBAction)addList;

//! Action called when the user wants to come back to this view.
- (IBAction)backToLists;

//@}

@end
