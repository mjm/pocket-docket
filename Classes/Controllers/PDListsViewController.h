#import "PDEditListViewController.h"

//! A view controller that displays all of the users lists.
/*!
 
 Allows the user to drill-down into a specific list, remove lists, or create new lists.
 
 \nosubgrouping
 */
@interface PDListsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PDEditListViewControllerDelegate, NSFetchedResultsControllerDelegate> {
	//! \name Handling State
	//@{
	
	BOOL isAdd;
	BOOL userIsMoving;
	
	//@}
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;

//! \name Actions
//@{

//! Action called when the user wants to create a new list.
- (IBAction)addList;

//@}

@end
