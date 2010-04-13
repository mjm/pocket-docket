#import "DOListsViewController.h"

#import "DOEditListViewController.h"
#import "../PDPersistenceController.h"
#import "../Views/PDListTableCell.h"
#import "../Views/PDListProgressView.h"
#import "../Models/PDList.h"

@interface DOListsViewController (PrivateMethods)

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list;

@end

@implementation DOListsViewController (PrivateMethods)

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list {
	if ([list.entries count] == 0) {
		cell.progressView.progress = 0.0;
	} else {
		cell.progressView.progress = ((CGFloat) [list.completedEntries count]) / ((CGFloat) [list.entries count]);
	}
	cell.titleLabel.text = list.title;
	cell.completionLabel.text = [NSString stringWithFormat:@"%d of %d completed", [list.completedEntries count], [list.entries count]];
}

@end


@implementation DOListsViewController

@synthesize fetchedResultsController;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSLog(@"Test");
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Managing Persistence

- (PDPersistenceController *)persistenceController {
	return persistenceController;
}

- (void)setPersistenceController:(PDPersistenceController *)controller {
	persistenceController = [controller retain];
	
	self.fetchedResultsController = [self.persistenceController listsFetchedResultsController];
	//self.fetchedResultsController.delegate = self;
	
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
}

#pragma mark -
#pragma mark Actions

- (IBAction)addList {
	PDList *list = [self.persistenceController createList];
	DOEditListViewController *controller = [[DOEditListViewController alloc] initWithList:list];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	
	UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
	popoverController.popoverContentSize = CGSizeMake(320.0, 100.0);
	[navController release];
	
	[popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ListCell = @"ListCell";
	
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	PDListTableCell *cell = (PDListTableCell *) [tableView dequeueReusableCellWithIdentifier:ListCell];
	if (!cell) {
		cell = [PDListTableCell listTableCell];
	}
	
	[self configureCell:cell withList:list];
	
	NSLog(@"lists returns cell: %@", cell);
	return cell;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
	[super dealloc];
}

@end
