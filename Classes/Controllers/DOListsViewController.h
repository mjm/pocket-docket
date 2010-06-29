#import "DOEditListViewController.h"

@class DOEntriesViewController;

@protocol DOListsViewControllerDelegate;

@interface DOListsViewController : UITableViewController <DOEditListViewControllerDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate> {
	BOOL userIsMoving;
}

@property (nonatomic, assign) IBOutlet id <DOListsViewControllerDelegate> delegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet DOEntriesViewController *entriesViewController;

- (IBAction)addList;

@end

@protocol DOListsViewControllerDelegate <NSObject>

- (void)listsController:(DOListsViewController *)controller didSelectList:(PDList *)list;
- (BOOL)listsControllerShouldDisplayControllerInPopover:(DOListsViewController *)controller;

@end