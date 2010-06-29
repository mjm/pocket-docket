#import "../PDKeyboardObserver.h"

@class PDList;

//! A view controller for displaying the entries in a list.
@interface PDEntriesViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate, PDKeyboardObserverDelegate, MFMailComposeViewControllerDelegate> {
	
	BOOL userIsMoving;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITextField *newEntryField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic, retain) PDKeyboardObserver *keyboardObserver;

//! \name Initializing a View Controller
//@{

//! Creates a new view controller that will show entries in a list.
/*!
 \param aList The list whose entries should be displayed.
 \return A new view controller.
 */
- (id)initWithList:(PDList *)aList;

//@}
//! \name Actions
//@{

- (IBAction)addListEntry;
- (IBAction)emailList;

//@}

@end
