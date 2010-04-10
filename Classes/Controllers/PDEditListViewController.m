#import "PDEditListViewController.h"

#import "../Models/PDList.h"
#import "../Views/PDTextFieldCell.h"

@implementation PDEditListViewController

@synthesize list, delegate, titleCell, navItem, navBar, table;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithList:(PDList *)aList {
	if (![super initWithNibName:@"PDEditListView" bundle:nil])
		return nil;
	
	self.list = aList;
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController) {
		self.navigationItem.title = self.navItem.title;
		self.navigationItem.rightBarButtonItem = self.navItem.rightBarButtonItem;
		[self.navBar removeFromSuperview];
		
		[self.table setFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];
	} else {
		self.navItem.title = self.title;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Actions

- (IBAction)saveList {
	self.list.title = self.titleCell.textField.text;
	[self.delegate editListController:self listDidChange:self.list];
}

- (IBAction)closeList {
	[self.delegate editListController:self listDidNotChange:self.list];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *Cell = @"TextField";
	
	PDTextFieldCell *cell = (PDTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
	if (!cell) {
		cell = [PDTextFieldCell textFieldCell];
	}
	
	cell.textField.text = list.title;
	[cell.textField becomeFirstResponder];
	self.titleCell = cell;
	
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
    [super dealloc];
}

@end
