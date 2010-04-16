#import "DOEditListViewController.h"

@class PDPersistenceController;
@class DOEntriesViewController;

@interface DOListsViewController : UITableViewController <DOEditListViewControllerDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate> {
	PDPersistenceController *persistenceController;
	NSFetchedResultsController *fetchedResultsController;
	UIPopoverController *popoverController;
	
	IBOutlet DOEntriesViewController *entriesViewController;
	
	BOOL userIsMoving;
}

@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet DOEntriesViewController *entriesViewController;

- (IBAction)addList;

@end
