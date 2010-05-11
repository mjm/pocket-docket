#import "DONewEntryViewController.h"

#import "../Models/PDListEntry.h"
#import "../Views/PDTextFieldCell.h"

@implementation DONewEntryViewController

@synthesize delegate, entry, textField;
@synthesize table, doneButton;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry {
	if (![super initWithNibName:@"DONewEntryView" bundle:nil])
		return nil;

	self.title = @"New Entry";
	self.entry = aEntry;
	self.contentSizeForViewInPopover = CGSizeMake(320, 63);
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (!didSave) {
		[self.delegate newEntryController:self didCancelEntry:self.entry];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.textField = nil;
	self.table = nil;
	self.doneButton = nil;
}

#pragma mark -
#pragma mark Actions

- (IBAction)doneAdding {
	// turn off any cancelling on disappear, since the view should be dismissed by the delegate
	didSave = YES;
	
	if ([self.textField.text length] == 0) {
		[self.delegate newEntryController:self didCancelEntry:self.entry];
		return;
	}
	
	self.entry.text = self.textField.text;
	[self.delegate newEntryController:self didCreateEntry:self.entry shouldDismiss:YES];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *Cell = @"TextField";
	
	PDTextFieldCell *cell = (PDTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
	if (!cell) {
		cell = [PDTextFieldCell textFieldCell];
		cell.textField.delegate = self;
		
		self.textField = cell.textField;
	}
	
	cell.textField.text = @"";
	cell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	cell.textField.returnKeyType = UIReturnKeyNext;
	cell.textField.enablesReturnKeyAutomatically = YES;
	[cell.textField becomeFirstResponder];
	
	return cell;
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.entry.text = self.textField.text;
	[self.delegate newEntryController:self didCreateEntry:self.entry shouldDismiss:NO];
	
	self.textField.text = self.entry.text;
	
	return NO;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.delegate = nil;
	self.entry = nil;
	self.textField = nil;
	self.table = nil;
	self.doneButton = nil;
    [super dealloc];
}

@end
