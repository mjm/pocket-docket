#import "PDCommentViewController.h"

@implementation PDCommentViewController

@synthesize delegate, comment;
@synthesize textView, saveButton;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithComment:(NSString *)aComment {
	if (![super initWithNibName:@"PDCommentView" bundle:nil])
		return nil;
	
	self.comment = aComment;
	self.title = @"Comment";
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.saveButton;
	self.textView.text = self.comment;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return !keyboardIsShowing;
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.textView = nil;
	self.saveButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)note {
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
	
	keyboardHeight = keyboardBounds.size.height;
	
	if (!keyboardIsShowing) {
		keyboardIsShowing = YES;
		
		CGRect frame = self.view.frame;
		frame.size.height -= keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		NSDictionary *info = [note userInfo];
		NSValue *value = [info valueForKey:UIKeyboardAnimationCurveUserInfoKey];
		UIViewAnimationCurve curve;
		[value getValue:&curve];
		[UIView setAnimationCurve:curve];
		
		value = [info valueForKey:UIKeyboardAnimationDurationUserInfoKey];
		NSTimeInterval duration;
		[value getValue:&duration];
		[UIView setAnimationDuration:duration];
		
		self.view.frame = frame;
		
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification *)note {
	if (keyboardIsShowing) {
		keyboardIsShowing = NO;
		
		CGRect frame = self.view.frame;
		frame.size.height += keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelay:0.0f];
		self.view.frame = frame;
		
		[UIView commitAnimations];
	}
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
	self.textView = nil;
	self.saveButton = nil;
    [super dealloc];
}


@end
