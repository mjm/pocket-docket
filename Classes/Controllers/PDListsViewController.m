#import "PDListsViewController.h"

#import "PDEditListViewController.h"
#import "PDEntriesViewController.h"
#import "../PDPersistenceController.h"
#import "../Models/PDList.h"
#import "../Views/PDListTableCell.h"

#pragma mark Private Methods

@interface PDListsViewController (PrivateMethods)

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list;

- (void)doneEditingList:(PDList *)list;

@end

@implementation PDListsViewController (PrivateMethods)

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list {
	cell.titleLabel.text = list.title;
	cell.completionLabel.text = [NSString stringWithFormat:@"%@ of ? completed", list.order];
}

- (void)doneEditingList:(PDList *)list {
	if (isAdd) {
		[self dismissModalViewControllerAnimated:YES];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
		
		NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:list];
		[self.table deselectRowAtIndexPath:indexPath animated:YES];
	}
}

@end

#pragma mark -

@implementation PDListsViewController

@synthesize persistenceController, fetchedResultsController;
@synthesize table, editButton, doneButton, addButton;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithPersistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDListsView" bundle:nil])
		return nil;
	
	self.persistenceController = controller;
	self.fetchedResultsController = [controller listsFetchedResultsController];
	self.fetchedResultsController.delegate = self;
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Lists";
	self.navigationItem.leftBarButtonItem = self.editButton;
	self.navigationItem.rightBarButtonItem = self.addButton;
	
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
}

- (void)viewWillAppear:(BOOL)animated {
	// Make sure the table is not in editing mode.
	[self doneEditingLists];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.editButton = nil;
	self.doneButton = nil;
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

- (IBAction)addList {
	isAdd = YES;
	
	PDList *list = [self.persistenceController createList];
	
	PDEditListViewController *editController = [[PDEditListViewController alloc] initWithList:list];
	editController.title = @"New List";
	editController.delegate = self;
	
	[self presentModalViewController:editController animated:YES];
	[editController release];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo =
		[[self.fetchedResultsController sections] objectAtIndex:section];
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
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toIndexPath:(NSIndexPath *)destinationIndexPath {
	userIsMoving = YES;
	
	PDList *list = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
	[self.persistenceController moveList:list fromRow:sourceIndexPath.row toRow:destinationIndexPath.row];
	
	userIsMoving = NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.persistenceController deleteList:list];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([self.table isEditing]) {
		isAdd = NO;
		
		PDEditListViewController *editController = [[PDEditListViewController alloc] initWithList:list];
		editController.delegate = self;
		
		[self.navigationController pushViewController:editController animated:YES];
		[editController release];
	} else {
		PDEntriesViewController *entriesController = [[PDEntriesViewController alloc] initWithList:list
																			 persistenceController:self.persistenceController];
		// TODO set delegate
		
		[self.navigationController pushViewController:entriesController animated:YES];
		[entriesController release];
	}
}

#pragma mark -
#pragma mark Edit List Controller Delegate Methods

- (void)editListController:(PDEditListViewController *)controller listDidChange:(PDList *)list {
	[self doneEditingList:list];
	[self.persistenceController save];
}

- (void)editListController:(PDEditListViewController *)controller listDidNotChange:(PDList *)list {
	[self doneEditingList:list];
	[self.persistenceController deleteList:list];
}

#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (userIsMoving)
		return;
	
	[self.table beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (userIsMoving)
		return;
	
	[self.table endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.table insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(PDListTableCell *) [self.table cellForRowAtIndexPath:indexPath]
					   withList:anObject];
			break;
		case NSFetchedResultsChangeMove:
			if (!userIsMoving) {
				[self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
				[self.table insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
			}
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {
	return;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
	
	self.editButton = nil;
	self.doneButton = nil;
	self.addButton = nil;
	
    [super dealloc];
}


@end
