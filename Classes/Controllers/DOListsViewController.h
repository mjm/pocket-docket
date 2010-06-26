#import "DOEditListViewController.h"

@class PDPersistenceController;
@class DOEntriesViewController;

@protocol DOListsViewControllerDelegate;

@interface DOListsViewController : UITableViewController <DOEditListViewControllerDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate> {
	PDPersistenceController *persistenceController;
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
- (BOOL)listsControllerShouldDisplayControllerInPopover:(DOListsViewController *)controller;

@end