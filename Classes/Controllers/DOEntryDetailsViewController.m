#import "DOEntryDetailsViewController.h"

#import "../Models/PDListEntry.h"

#pragma mark Private Methods

@interface DOEntryDetailsViewController ()

- (void)updateTitleBarWithTextField:(UITextField *)textField;

- (UITextField *)summaryTextField;
- (UITextView *)commentTextView;

@end

#pragma mark -

@implementation DOEntryDetailsViewController

@synthesize entry, delegate;
@synthesize cancelButton, saveButton, textCell, commentCell;

- (void)updateTitleBarWithTextField:(UITextField *)textField {
	if ([textField.text length] > 0) {
		self.navigationItem.title = textField.text;
	} else {
		self.navigationItem.title = isNew ? @"New Entry" : @"Edit Entry";
	}
}

- (UITextField *)summaryTextField {
	return (UITextField *) [self.textCell viewWithTag:1];
}

- (UITextView *)commentTextView {
	return (UITextView *) [self.commentCell viewWithTag:1];
}

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry {
	if (![super initWithNibName:@"DOEntryDetailsView" bundle:nil])
		return nil;
	
	self.entry = aEntry;
	return self;
}

- (id)initWithNewEntry:(PDListEntry *)aEntry {
	if (![self initWithEntry:aEntry])
		return nil;
	
	isNew = YES;
	return self;
}

- (id)initWithExistingEntry:(PDListEntry *)aEntry {
	if (![self initWithEntry:aEntry])
		return nil;
	
	isNew = NO;
	return self;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.saveButton;
	
	[[self summaryTextField] setText:self.entry.text];
	[[self commentTextView] setText:self.entry.comment];
	
	[self updateTitleBarWithTextField:[self summaryTextField]];
}

- (void)viewDidAppear:(BOOL)animated {
	[[self summaryTextField] becomeFirstResponder];
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
	self.entry.text = [[self summaryTextField] text];
	self.entry.comment = [[self commentTextView] text];
	
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
	[[self commentTextView] becomeFirstResponder];
	
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
