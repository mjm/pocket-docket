#import "DOEditListViewController.h"
#import "DOEntryDetailsViewController.h"

@class PDList;
@class PDPersistenceController;

@interface DOEntriesViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DOEditListViewControllerDelegate, UIPopoverControllerDelegate, DOEntryDetailsViewControllerDelegate> {
	PDList *list;
	PDPersistenceController *persistenceController;
	
	UIPopoverController *popoverController;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *editButton;
}

@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;

- (IBAction)editList;
- (IBAction)addEntry;

@end
