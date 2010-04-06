@protocol PDCommentViewControllerDelegate;

@interface PDCommentViewController : UIViewController {
	id <PDCommentViewControllerDelegate> delegate;
	
	NSString *comment;
	
	IBOutlet UITextView *textView;
	IBOutlet UIBarButtonItem *saveButton;
	
	BOOL keyboardIsShowing;
	CGFloat keyboardHeight;
}

@property (nonatomic, assign) id <PDCommentViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

- (id)initWithComment:(NSString *)aComment;

- (IBAction)saveComment;

@end

@protocol PDCommentViewControllerDelegate

- (void)commentController:(PDCommentViewController *)controller commentDidChange:(NSString *)comment;

@end