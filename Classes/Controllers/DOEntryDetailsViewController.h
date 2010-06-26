@class PDListEntry;
@class PDKeyboardObserver;

@protocol DOEntryDetailsViewControllerDelegate;

@interface DOEntryDetailsViewController : UIViewController <UITextFieldDelegate> {
	BOOL isNew;
}

@property (nonatomic, retain) PDListEntry *entry;
@property (nonatomic, assign) id <DOEntryDetailsViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UITextField *summaryTextField;
@property (nonatomic, retain) IBOutlet UITextView *commentTextView;
@property (nonatomic, retain) PDKeyboardObserver *keyboardObserver;

- (id)initWithNewEntry:(PDListEntry *)entry delegate:(id <DOEntryDetailsViewControllerDelegate>)aDelegate;
- (id)initWithExistingEntry:(PDListEntry *)entry delegate:(id <DOEntryDetailsViewControllerDelegate>)aDelegate;

- (IBAction)cancelEntry;
- (IBAction)saveEntry;
- (IBAction)updateTitleBarWithTextField:(UITextField *)textField;

- (void)presentModalToViewController:(UIViewController *)controller;

@end

@protocol DOEntryDetailsViewControllerDelegate

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didSaveEntry:(PDListEntry *)entry;
- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didCancelEntry:(PDListEntry *)entry;

@end
