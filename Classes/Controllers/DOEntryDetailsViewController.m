#import "DOEntryDetailsViewController.h"

#import "../PDKeyboardObserver.h"
#import "../Models/PDListEntry.h"

@implementation DOEntryDetailsViewController

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry delegate:(id <DOEntryDetailsViewControllerDelegate>)aDelegate {
	if (![super initWithNibName:@"DOEntryDetailsView" bundle:nil])
		return nil;
	
	self.entry = aEntry;
	self.delegate = aDelegate;
	return self;
}

- (id)initWithNewEntry:(PDListEntry *)aEntry delegate:(id <DOEntryDetailsViewControllerDelegate>)aDelegate {
	if (![self initWithEntry:aEntry delegate:aDelegate])
		return nil;
	
	isNew = YES;
	return self;
}

- (id)initWithExistingEntry:(PDListEntry *)aEntry delegate:(id <DOEntryDetailsViewControllerDelegate>)aDelegate {
	if (![self initWithEntry:aEntry delegate:aDelegate])
		return nil;
	
	isNew = NO;
	return self;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.keyboardObserver = [PDKeyboardObserver keyboardObserverWithViewController:self delegate:nil];
	
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.saveButton;
	
	self.summaryTextField.text = self.entry.text;
	self.commentTextView.text = self.entry.comment;
	
	[self updateTitleBarWithTextField:self.summaryTextField];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.keyboardObserver registerNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.keyboardObserver unregisterNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.summaryTextField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.cancelButton = nil;
	self.saveButton = nil;
	self.summaryTextField = nil;
	self.commentTextView = nil;
	self.keyboardObserver = nil;
}

#pragma mark -
#pragma mark Actions

- (IBAction)cancelEntry {
	[self.delegate entryDetailsController:self didCancelEntry:self.entry];
}

- (IBAction)saveEntry {
	self.entry.text = self.summaryTextField.text;
	self.entry.comment = self.commentTextView.text;
	
	[self.delegate entryDetailsController:self didSaveEntry:self.entry];
}

- (void)updateTitleBarWithTextField:(UITextField *)textField {
	if ([textField.text length] > 0) {
		self.navigationItem.title = textField.text;
	} else {
		self.navigationItem.title = isNew
				? NSLocalizedString(@"New Entry", nil)
				: NSLocalizedString(@"Edit Entry", nil);
	}
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.commentTextView becomeFirstResponder];
	
	return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[self performSelector:@selector(updateTitleBarWithTextField:) withObject:textField afterDelay:0.5];
	
	return YES;
}

#pragma mark -
#pragma mark Presenting a View Controller

- (void)presentModalToViewController:(UIViewController *)controller {
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
	navController.modalPresentationStyle = UIModalPresentationPageSheet;
	
	[controller presentModalViewController:navController animated:YES];
	[navController release];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.entry = nil;
	self.delegate = nil;
	self.cancelButton = nil;
	self.saveButton = nil;
	self.summaryTextField = nil;
	self.commentTextView = nil;
	[super dealloc];
}

@end
