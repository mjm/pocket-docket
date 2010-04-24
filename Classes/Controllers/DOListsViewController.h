#import "DOEditListViewController.h"

@class PDPersistenceController;
@class DOEntriesViewController;

@protocol DOListsViewControllerDelegate;

@interface DOListsViewController : UITableViewController <DOEditListViewControllerDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate> {
	id <DOListsViewControllerDelegate> delegate;
	
	PDPersistenceController *persistenceController;
	NSFetchedResultsController *fetchedResultsController;
	UIPopoverController *popoverController;
	
	IBOutlet DOEntriesViewController *entriesViewController;
	
	BOOL userIsMoving;
}

@property (nonatomic, assign) id <DOListsViewControllerDelegate> delegate;
@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet DOEntriesViewController *entriesViewController;

- (IBAction)addList;

@end

@protocol DOListsViewControllerDelegate <NSObject>

- (void)listsController:(DOListsViewController *)controller didSelectList:(PDList *)list;

@end