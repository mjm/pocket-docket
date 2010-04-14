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
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.editingAccessoryType = UITableViewCellAccessoryNone;
}

@end


@implementation DOListsViewController

@synthesize persistenceController, fetchedResultsController, popoverController, table;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.popoverController = nil;
	self.table = nil;
}

#pragma mark -
#pragma mark Managing Persistence

- (void)setPersistenceController:(PDPersistenceController *)controller {
	persistenceController = [controller retain];
	
	self.fetchedResultsController = [self.persistenceController listsFetchedResultsController];
	self.fetchedResultsController.delegate = self;
	
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
}

#pragma mark -
#pragma mark Actions

- (IBAction)addList {
	[self.persistenceController.undoManager beginUndoGrouping];
	PDList *list = [self.persistenceController createList];
	
	DOEditListViewController *controller = [[DOEditListViewController alloc] initWithList:list];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	
	if (!popoverController) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
	} else {
		self.popoverController.contentViewController = navController;
	}
	self.popoverController.popoverContentSize = CGSizeMake(320.0, 100.0);
	self.popoverController.delegate = self;
	[navController release];
	
	[self.popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
								   permittedArrowDirections:UIPopoverArrowDirectionAny
												   animated:YES];
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

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.persistenceController deleteList:list];
	[self.persistenceController save];
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 65.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"selected index path: %@", indexPath);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"deselected index path: %@", indexPath);
}

#pragma mark -
#pragma mark Edit List Delegate Methods

// Called when the user hits the save button in the popover.
- (void)editListController:(DOEditListViewController *)controller listDidChange:(PDList *)list {
	[self.persistenceController.undoManager endUndoGrouping];
	[self.persistenceController save];
	[self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Popover Controller Delegate Methods

// Called when the user dismisses the popover without saving.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.persistenceController.undoManager endUndoGrouping];
	[self.persistenceController.undoManager undo];
	[self.persistenceController save];
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
	self.popoverController = nil;
	self.table = nil;
	[super dealloc];
}

@end
