#import "PDEntriesViewController.h"

#import "../PDPersistenceController.h"
#import "../Models/PDList.h"

@implementation PDEntriesViewController

@synthesize list, persistenceController, fetchedResultsController;
@synthesize newEntryField;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithList:(PDList *)aList persistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDEntriesView" bundle:nil])
		return nil;
	
	self.list = aList;
	self.persistenceController = controller;
	self.fetchedResultsController = [self.persistenceController entriesFetchedResultsControllerForList:self.list];
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.list.title;
	
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return !keyboardIsShowing;
}

- (void)viewDidUnload {
	self.newEntryField = nil;
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)note {
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardBounds];
	
	NSLog(@"Keyboard bounds: (%f, %f) (%f, %f)", keyboardBounds.origin.x, keyboardBounds.origin.y,
		  keyboardBounds.size.width, keyboardBounds.size.height);
	keyboardHeight = keyboardBounds.size.height;
	
	if (!keyboardIsShowing) {
		keyboardIsShowing = YES;
		
		CGRect frame = self.view.frame;
		frame.size.height -= keyboardHeight;
		
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelay:0.0f];
		self.view.frame = frame;
		
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification *)note {
	NSLog(@"Hiding keyboard");
	
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
#pragma mark Scroll View Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.newEntryField resignFirstResponder];
}

#pragma mark -
#pragma mark Actions

- (IBAction)addListEntry {
	[self.newEntryField resignFirstResponder];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
	self.newEntryField = nil;
    [super dealloc];
}

@end
