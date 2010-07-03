@class PDKeyboardObserver;
@class PDList;

@protocol PDImportEntriesViewControllerDelegate;

@interface PDImportEntriesViewController : UIViewController {}

@property (nonatomic, assign) id <PDImportEntriesViewControllerDelegate> delegate;
@property (nonatomic, retain) PDList *list;

@property (nonatomic, retain) NSString *importText;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *importButton;
@property (nonatomic, retain) PDKeyboardObserver *keyboardObserver;

- (id)initWithList:(PDList *)aList;

- (IBAction)cancelImport;
- (IBAction)importEntries;

@end


@protocol PDImportEntriesViewControllerDelegate <NSObject>

- (void)dismissImportEntriesController:(PDImportEntriesViewController *)controller;

@end

