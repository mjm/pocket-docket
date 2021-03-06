#import "DOEditListViewController.h"

#import "PDList.h"
#import "../Views/PDTextFieldCell.h"

@implementation DOEditListViewController

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithList:(PDList *)aList {
	if (![super initWithNibName:@"DOEditListView" bundle:nil])
		return nil;
	
	self.title = NSLocalizedString(@"Edit List", nil);
	self.list = aList;
	self.contentSizeForViewInPopover = CGSizeMake(320, 63);
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	didSave = NO;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (!didSave && [self.delegate respondsToSelector:@selector(editListController:listDidNotChange:)]) {
		[self.delegate editListController:self listDidNotChange:self.list];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.table = nil;
	self.saveButton = nil;
}

#pragma mark -
#pragma mark Actions

- (IBAction)textChanged:(UITextField *)sender
{
	self.list.title = sender.text;
}

- (IBAction)saveList
{
	self.list.title = self.titleCell.textField.text;
	
	didSave = YES;
	[self.delegate editListController:self listDidChange:self.list];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *Cell = @"TextField";
	
	PDTextFieldCell *cell = (PDTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
	if (!cell)
	{
		cell = [PDTextFieldCell textFieldCell];
		cell.textField.delegate = self;
		[cell.textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
	}
	
	cell.textField.text = self.list.title;
	[cell.textField becomeFirstResponder];
	self.titleCell = cell;

	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self saveList];
	
	return NO;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
	self.titleCell = nil;
	self.table = nil;
	self.saveButton = nil;
	[super dealloc];
}

@end
