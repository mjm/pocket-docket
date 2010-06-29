@class PDList;
@class PDTextFieldCell;

@protocol DOEditListViewControllerDelegate;

//! A view controller that allows the user to edit the title of a list.
@interface DOEditListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	BOOL didSave;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, assign) id <DOEditListViewControllerDelegate> delegate;
@property (nonatomic, retain) PDTextFieldCell *titleCell;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

//! \name Initializing a View Controller
//@{

//! Creates a new view controller that will edit a list.
/*!
 \param aList the list this controller will edit.
 \return The new view controller.
 */
- (id)initWithList:(PDList *)aList;

//@}
//! \name Actions
//@{

//! Action called when the user wants to save and close the list they are editing.
- (IBAction)saveList;

//@}

@end

//! Protocol for DOEditListViewController delegates.
@protocol DOEditListViewControllerDelegate <NSObject>

//! Called when the user is done editing the list and wants to save their changes.
/*!
 \param controller The controller that finished editing.
 \param list The list the user was editing with its state updated.
 */
- (void)editListController:(DOEditListViewController *)controller
			 listDidChange:(PDList *)list;

@optional
- (void)editListController:(DOEditListViewController *)controller
		  listDidNotChange:(PDList *)list;

@end