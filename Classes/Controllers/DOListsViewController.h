#import "DOEditListViewController.h"
#import "PDListsController.h"

@class DOEntriesViewController;

@protocol DOListsViewControllerDelegate;

@interface DOListsViewController : UITableViewController <DOEditListViewControllerDelegate, UIPopoverControllerDelegate, PDListsControllerDelegate> {}

@property (nonatomic, assign) IBOutlet id <DOListsViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet PDListsController *listsController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (IBAction)addList;
- (IBAction)refreshLists;
- (IBAction)stopRefreshing;

@end

@protocol DOListsViewControllerDelegate <NSObject>

- (void)listsController:(DOListsViewController *)controller didSelectList:(PDList *)list;
- (BOOL)listsControllerShouldDisplayControllerInPopover:(DOListsViewController *)controller;

@end