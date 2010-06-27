#import "DOListsViewController.h"
#import "DOEditListViewController.h"
#import "DONewEntryViewController.h"
#import "DOEntryDetailsViewController.h"

@class PDList;
@class PDPersistenceController;
@class DOListsViewController;

@interface DOEntriesViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DOEditListViewControllerDelegate, UIPopoverControllerDelegate, DOEntryDetailsViewControllerDelegate, NSFetchedResultsControllerDelegate, DOListsViewControllerDelegate, DONewEntryViewControllerDelegate, MFMailComposeViewControllerDelegate> {
	PDList *list;
	BOOL userIsMoving;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *listsPopoverController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet DOListsViewController *listsViewController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureRecognizer;

- (IBAction)emailList;
- (IBAction)editList;
- (IBAction)addEntry;

@end
