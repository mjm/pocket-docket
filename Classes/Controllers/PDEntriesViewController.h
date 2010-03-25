@class PDList;
@class PDPersistenceController;

//! A view controller for displaying the entries in a list.
@interface PDEntriesViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
	PDList *list;
	PDPersistenceController *persistenceController;
	NSFetchedResultsController *fetchedResultsController;
	
	IBOutlet UIBarButtonItem *editButton;
	IBOutlet UIBarButtonItem *doneButton;
	IBOutlet UITableView *table;
	IBOutlet UITextField *newEntryField;
	
	BOOL keyboardIsShowing;
	CGFloat keyboardHeight;
	
	BOOL userIsMoving;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UITextField *newEntryField;

//! \name Initializing a View Controller
//@{

//! Creates a new view controller that will show entries in a list.
/*!
 \param aList The list whose entries should be displayed.
 \param controller The persistence controller to use for data operations.
 \return A new view controller.
 */
- (id)initWithList:(PDList *)aList persistenceController:(PDPersistenceController *)controller;

//@}
//! \name Actions
//@{

- (IBAction)editEntries;

- (IBAction)doneEditingEntries;

- (IBAction)addListEntry;

//@}

@end
