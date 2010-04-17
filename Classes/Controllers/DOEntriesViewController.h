#import "DOEditListViewController.h"
#import "DOEntryDetailsViewController.h"

@class PDList;
@class PDPersistenceController;
@class DOListsViewController;

@interface DOEntriesViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DOEditListViewControllerDelegate, UIPopoverControllerDelegate, DOEntryDetailsViewControllerDelegate> {
	PDList *list;
	PDPersistenceController *persistenceController;
	
	UIPopoverController *popoverController;
	IBOutlet DOListsViewController *listsViewController;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *editButton;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) DOListsViewController *listsViewController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;

- (IBAction)editList;
- (IBAction)addEntry;

@end
