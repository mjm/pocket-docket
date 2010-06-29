#import "PDCommentViewController.h"
#import "../PDKeyboardObserver.h"

@class PDListEntry;

//! A view controller for showing the details of a list entry.
@interface PDEntryDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PDCommentViewControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate> {
	BOOL didCancel;
}

@property (nonatomic, retain) PDListEntry *entry;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) PDKeyboardObserver *keyboardObserver;

//! \name Initializing a View Controller
//@{

//! Creates a new view controller to display an entry.
/*!
 \param entry The entry to display.
 \return A new view controller.
 */
- (id)initWithEntry:(PDListEntry *)entry;

//@}

- (IBAction)cancelEditing;

@end
