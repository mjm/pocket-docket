#import "DOEditListViewController.h"

@class PDPersistenceController;

@interface DOListsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, DOEditListViewControllerDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate> {
	PDPersistenceController *persistenceController;
	NSFetchedResultsController *fetchedResultsController;
	UIPopoverController *popoverController;
	
	IBOutlet UITableView *table;
	BOOL userIsMoving;
}

@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UITableView *table;

- (IBAction)addList;

@end
