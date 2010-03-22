#import "PDEditListViewController.h"

#import "../Models/PDList.h"
#import "../Views/PDTextFieldCell.h"

@implementation PDEditListViewController

@synthesize list, delegate, titleCell, navItem;

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
	
	self.navItem.title = self.title;
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
	static NSString *Cell = @"Cell";
	
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



#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
    [super dealloc];
}

@end
