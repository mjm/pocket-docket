@class PDListEntry;

@protocol DONewEntryViewControllerDelegate;

@interface DONewEntryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	BOOL didSave;
}

@property (nonatomic, assign) id <DONewEntryViewControllerDelegate> delegate;
@property (nonatomic, retain) PDListEntry *entry;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (id)initWithEntry:(PDListEntry *)aEntry;

- (IBAction)textChanged:(UITextField *)sender;
- (IBAction)doneAdding;

@end

@protocol DONewEntryViewControllerDelegate <NSObject>

- (void)newEntryController:(DONewEntryViewController *)controller
			didCreateEntry:(PDListEntry *)entry
			 shouldDismiss:(BOOL)dismiss;

- (void)newEntryController:(DONewEntryViewController *)controller
			didCancelEntry:(PDListEntry *)entry;

@end