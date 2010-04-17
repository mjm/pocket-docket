@class PDListEntry;

@protocol DOEntryDetailsViewControllerDelegate;

@interface DOEntryDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	PDListEntry *entry;
	id <DOEntryDetailsViewControllerDelegate> delegate;
	
	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UIBarButtonItem *saveButton;
	
	IBOutlet UITableViewCell *textCell;
	IBOutlet UITableViewCell *commentCell;
	
	BOOL isNew;
}

@property (nonatomic, retain) PDListEntry *entry;
@property (nonatomic, assign) id <DOEntryDetailsViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UITableViewCell *textCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *commentCell;

- (id)initWithNewEntry:(PDListEntry *)entry delegate:(id <DOEntryDetailsViewControllerDelegate>)aDelegate;
- (id)initWithExistingEntry:(PDListEntry *)entry delegate:(id <DOEntryDetailsViewControllerDelegate>)aDelegate;

- (IBAction)cancelEntry;
- (IBAction)saveEntry;

- (void)presentModalToViewController:(UIViewController *)controller;

@end

@protocol DOEntryDetailsViewControllerDelegate

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didSaveEntry:(PDListEntry *)entry;
- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didCancelEntry:(PDListEntry *)entry;

@end
