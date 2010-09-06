@class PDList;
@class PDListEntry;

@protocol DONewEntryViewControllerDelegate;

@interface DONewEntryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	BOOL didSave;
}

@property (nonatomic, assign) id <DONewEntryViewControllerDelegate> delegate;
@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (id)initWithList:(PDList *)aList;

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