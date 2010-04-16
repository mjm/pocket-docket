#import "DOEntryDetailsViewController.h"

#import "../Models/PDListEntry.h"

#pragma mark Private Methods

@interface DOEntryDetailsViewController ()

- (void)updateTitleBarWithTextField:(UITextField *)textField;

@end

#pragma mark -

@implementation DOEntryDetailsViewController

@synthesize entry, delegate;
@synthesize cancelButton, saveButton, textCell, commentCell;

- (void)updateTitleBarWithTextField:(UITextField *)textField {
	if ([textField.text length] > 0) {
		self.navigationItem.title = textField.text;
	} else {
		self.navigationItem.title = @"New Entry";
	}
}

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry {
	if (![super initWithNibName:@"DOEntryDetailsView" bundle:nil])
		return nil;
	
	self.title = @"New Entry";
	self.entry = aEntry;
	return self;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (void)viewDidAppear:(BOOL)animated {
	UITextField *textField = (UITextField *) [self.textCell viewWithTag:1];
	[textField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.cancelButton = nil;
	self.saveButton = nil;
	self.textCell = nil;
	self.commentCell = nil;
}

#pragma mark -
#pragma mark Actions

- (IBAction)cancelEntry {
	[self.delegate entryDetailsController:self didCancelEntry:self.entry];
}

- (IBAction)saveEntry {
	UITextField *textField = (UITextField *) [self.textCell viewWithTag:1];
	UITextView *textView = (UITextView *) [self.commentCell viewWithTag:1];
	
	self.entry.text = textField.text;
	self.entry.comment = textView.text;
	
	[self.delegate entryDetailsController:self didSaveEntry:self.entry];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	static NSString *TextCell = @"TextCell";
	static NSString *CommentCell = @"CommentCell";
	
	if (indexPath.row == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:TextCell];
		if (!cell) {
			cell = self.textCell;
		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CommentCell];
		if (!cell) {
			cell = self.commentCell;
		}
	}
	
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1) {
		// TODO calculate this better.
		return 80.0f;
	}
	return 44.0f;
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	UITextView *textView = (UITextView *) [self.commentCell viewWithTag:1];
	[textView becomeFirstResponder];
	
	return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[self performSelector:@selector(updateTitleBarWithTextField:) withObject:textField afterDelay:0.5];
	
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[self performSelector:@selector(updateTitleBarWithTextField:) withObject:textField afterDelay:0.5];
	
	return YES;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.entry = nil;
	self.delegate = nil;
	self.cancelButton = nil;
	self.saveButton = nil;
	[super dealloc];
}

@end
