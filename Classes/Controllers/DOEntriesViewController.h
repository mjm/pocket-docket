#import "DOEditListViewController.h"
#import "DOEntryDetailsViewController.h"

@class PDList;
@class PDPersistenceController;
@class DOListsViewController;

@interface DOEntriesViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DOEditListViewControllerDelegate, UIPopoverControllerDelegate, DOEntryDetailsViewControllerDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate> {
	PDList *list;
	PDPersistenceController *persistenceController;
	NSFetchedResultsController *fetchedResultsController;
	
	UIPopoverController *popoverController;
	IBOutlet DOListsViewController *listsViewController;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *editButton;
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet UITableView *table;
	
	PDListEntry *selectedEntry;
	CGPoint popoverPoint;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) DOListsViewController *listsViewController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) PDListEntry *selectedEntry;

- (IBAction)editList;
- (IBAction)addEntry;

@end
