#import "DOListsViewController.h"
#import "DOEditListViewController.h"
#import "DONewEntryViewController.h"
#import "DOEntryDetailsViewController.h"
#import "PDImportEntriesViewController.h"
#import "PDEntriesController.h"

@interface DOEntriesViewController : PDViewController <UISplitViewControllerDelegate, DOEditListViewControllerDelegate, UIPopoverControllerDelegate, DOEntryDetailsViewControllerDelegate, DOListsViewControllerDelegate, DONewEntryViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, PDImportEntriesViewControllerDelegate, PDEntriesControllerDelegate> {}

@property (nonatomic, retain) IBOutlet PDEntriesController *entriesController;
@property (nonatomic, retain) IBOutlet PDListsController *listsController;
@property (nonatomic, retain) UIPopoverController *listsPopoverController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureRecognizer;

- (IBAction)showActionMenu;
- (IBAction)emailList;
- (IBAction)importEntries;
- (IBAction)editList;
- (IBAction)addEntry;

@end
