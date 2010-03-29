#import "PDEntryDetailViewController.h"

#import "../Models/PDListEntry.h"
#import "../PDPersistenceController.h"

@implementation PDEntryDetailViewController

@synthesize entry, persistenceController;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithEntry:(PDListEntry *)aEntry persistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDEntryDetailView" bundle:nil])
		return nil;
	
	self.entry = aEntry;
	self.persistenceController = controller;
	
	self.title = @"Edit Entry";
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *Cell = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell] autorelease];
	}
	
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = self.entry.text;
			break;
		case 1:
			cell.textLabel.text = self.entry.comment;
			break;
	}
	
	return cell;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.entry = nil;
	self.persistenceController = nil;
    [super dealloc];
}

@end
