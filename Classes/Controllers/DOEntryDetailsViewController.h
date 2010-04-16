@class PDListEntry;

@protocol DOEntryDetailsViewControllerDelegate;

@interface DOEntryDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	PDListEntry *entry;
	id <DOEntryDetailsViewControllerDelegate> delegate;
	
	IBOutlet UIBarButtonItem *cancelButton;
	IBOutlet UIBarButtonItem *saveButton;
	
	IBOutlet UITableViewCell *textCell;
	IBOutlet UITableViewCell *commentCell;
}

@property (nonatomic, retain) PDListEntry *entry;
@property (nonatomic, assign) id <DOEntryDetailsViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UITableViewCell *textCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *commentCell;

- (id)initWithEntry:(PDListEntry *)entry;

- (IBAction)cancelEntry;
- (IBAction)saveEntry;

@end

@protocol DOEntryDetailsViewControllerDelegate

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didSaveEntry:(PDListEntry *)entry;
- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didCancelEntry:(PDListEntry *)entry;

@end
