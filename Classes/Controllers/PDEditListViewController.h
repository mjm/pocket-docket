#import "PDViewController.h"

@class PDList;
@class PDTextFieldCell;

@protocol PDEditListViewControllerDelegate;

//! A view controller that allows the user to edit the title of a list.
@interface PDEditListViewController : PDViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, assign) id <PDEditListViewControllerDelegate> delegate;
@property (nonatomic, retain) PDTextFieldCell *titleCell;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UITableView *table;

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

//! Action called when the user wants to close the list they are editing without saving.
- (IBAction)closeList;

//@}

@end

//! Protocol for PDEditListViewController delegates.
@protocol PDEditListViewControllerDelegate

//! Called when the user is done editing the list and wants to save their changes.
/*!
 \param controller The controller that finished editing.
 \param list The list the user was editing with its state updated.
 */
- (void)editListController:(PDEditListViewController *)controller
			 listDidChange:(PDList *)list;

//! Called when the user is done editing the list and wants to discard their changes.
/*!
 \param controller The controller that finished editing.
 \param list The list the user was editing unchanged.
 */
- (void)editListController:(PDEditListViewController *)controller
		  listDidNotChange:(PDList *)list;

@end