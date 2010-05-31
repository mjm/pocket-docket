#import "PDCommentViewController.h"

@implementation PDCommentViewController

@synthesize delegate, comment, keyboardObserver;
@synthesize textView, saveButton;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithComment:(NSString *)aComment {
	if (![super initWithNibName:@"PDCommentView" bundle:nil])
		return nil;
	
	self.comment = aComment;
	self.title = NSLocalizedString(@"Comment", nil);
	self.keyboardObserver = [[PDKeyboardObserver alloc] initWithViewController:self delegate:nil];
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.rightBarButtonItem = self.saveButton;
	self.textView.text = self.comment;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ![keyboardObserver isKeyboardShowing];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.textView = nil;
	self.saveButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[keyboardObserver registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
	[self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[keyboardObserver unregisterNotifications];
}

#pragma mark -
#pragma mark Actions

- (IBAction)saveComment {
	self.comment = self.textView.text;
	[self.delegate commentController:self commentDidChange:self.comment];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.comment = nil;
	self.delegate = nil;
	self.textView = nil;
	self.saveButton = nil;
	self.keyboardObserver = nil;
	[super dealloc];
}


@end
