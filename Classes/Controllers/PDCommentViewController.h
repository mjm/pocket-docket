#import "../PDKeyboardObserver.h"

@protocol PDCommentViewControllerDelegate;

@interface PDCommentViewController : UIViewController {
	id <PDCommentViewControllerDelegate> delegate;
	
	NSString *comment;
	
	IBOutlet UITextView *textView;
	IBOutlet UIBarButtonItem *saveButton;
	
	PDKeyboardObserver *keyboardObserver;
}

@property (nonatomic, assign) id <PDCommentViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) PDKeyboardObserver *keyboardObserver;

- (id)initWithComment:(NSString *)aComment;

- (IBAction)saveComment;

@end

@protocol PDCommentViewControllerDelegate

- (void)commentController:(PDCommentViewController *)controller commentDidChange:(NSString *)comment;

@end