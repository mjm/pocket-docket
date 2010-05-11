@class PDListEntry;

@protocol DONewEntryViewControllerDelegate;

@interface DONewEntryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	id <DONewEntryViewControllerDelegate> delegate;
	PDListEntry *entry;
	UITextField *textField;
	
	BOOL didSave;
	
	IBOutlet UITableView *table;
	IBOutlet UIBarButtonItem *doneButton;
}

@property (nonatomic, assign) id <DONewEntryViewControllerDelegate> delegate;
@property (nonatomic, retain) PDListEntry *entry;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (id)initWithEntry:(PDListEntry *)aEntry;

- (IBAction)doneAdding;

@end

@protocol DONewEntryViewControllerDelegate <NSObject>

- (void)newEntryController:(DONewEntryViewController *)controller
			didCreateEntry:(PDListEntry *)entry
			 shouldDismiss:(BOOL)dismiss;

- (void)newEntryController:(DONewEntryViewController *)controller
			didCancelEntry:(PDListEntry *)entry;

@end