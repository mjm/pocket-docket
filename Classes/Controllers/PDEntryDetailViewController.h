@class PDListEntry;
@class PDPersistenceController;

//! A view controller for showing the details of a list entry.
@interface PDEntryDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	PDListEntry *entry;
	PDPersistenceController *persistenceController;
	
	IBOutlet UITableView *table;
	
	CGFloat keyboardHeight;
	BOOL keyboardIsShowing;
}

@property (nonatomic, retain) PDListEntry *entry;
@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) UITableView *table;

//! \name Initializing a View Controller
//@{

//! Creates a new view controller to display an entry.
/*!
 \param entry The entry to display.
 \param controller The persistence controller to use.
 \return A new view controller.
 */
- (id)initWithEntry:(PDListEntry *)entry persistenceController:(PDPersistenceController *)controller;

@end
