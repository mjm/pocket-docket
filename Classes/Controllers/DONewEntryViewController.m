#import "DONewEntryViewController.h"

#import "PDListEntry.h"
#import "../Views/PDTextFieldCell.h"
#import "../Singletons/PDPersistenceController.h"

@implementation DONewEntryViewController

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithList:(PDList *)aList
{
	if (![super initWithNibName:@"DONewEntryView" bundle:nil])
		return nil;

	self.title = NSLocalizedString(@"New Entry", nil);
    self.list = aList;
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
		[self.delegate newEntryController:self didCancelEntry:nil];
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
		[self.delegate newEntryController:self didCancelEntry:nil];
		return;
	}
	
    PDListEntry *entry = [[PDPersistenceController sharedPersistenceController] createEntry:self.textField.text inList:self.list];
	[self.delegate newEntryController:self didCreateEntry:entry shouldDismiss:YES];
}

- (IBAction)textChanged:(UITextField *)sender {
	//self.entry.text = sender.text;
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
	if (!cell)
	{
		cell = [PDTextFieldCell textFieldCell];
		cell.textField.delegate = self;
		[cell.textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
		
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
    PDListEntry *entry = [[PDPersistenceController sharedPersistenceController] createEntry:self.textField.text inList:self.list];
	[self.delegate newEntryController:self didCreateEntry:entry shouldDismiss:NO];
	
	self.textField.text = @"";
	
	return NO;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.delegate = nil;
    self.list = nil;
	self.textField = nil;
	self.table = nil;
	self.doneButton = nil;
    [super dealloc];
}

@end
