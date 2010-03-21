#import "PDListsViewController.h"

#import "../PDPersistenceController.h"
#import "../Views/PDListTableCell.h"

@implementation PDListsViewController

@synthesize persistenceController;
@synthesize table, editButton, doneButton, addButton;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithPersistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDListsView" bundle:nil])
		return nil;
	
	self.persistenceController = controller;
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Lists";
	self.navigationItem.leftBarButtonItem = self.editButton;
	self.navigationItem.rightBarButtonItem = self.addButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.editButton = nil;
	self.addButton = nil;
}

#pragma mark -
#pragma mark Actions

- (IBAction)editLists {
	[self.table setEditing:YES animated:YES];
	self.navigationItem.leftBarButtonItem = doneButton;
}

- (IBAction)doneEditingLists {
	[self.table setEditing:NO animated:YES];
	self.navigationItem.leftBarButtonItem = editButton;
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ListCell = @"ListCell";
	
	PDListTableCell *cell = (PDListTableCell *) [tableView dequeueReusableCellWithIdentifier:ListCell];
	if (!cell) {
		cell = [PDListTableCell listTableCell];
	}
	
	cell.titleLabel.text = @"Title";
	cell.completionLabel.text = @"1 of 3 completed";
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toIndexPath:(NSIndexPath *)destinationIndexPath {
	
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.persistenceController = nil;
	self.editButton = nil;
	self.addButton = nil;
    [super dealloc];
}


@end
