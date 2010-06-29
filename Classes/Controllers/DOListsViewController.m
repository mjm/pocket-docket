#import "DOListsViewController.h"

#import "DOEntriesViewController.h"
#import "DOEditListViewController.h"
#import "../PDPersistenceController.h"
#import "../PDSettingsController.h"
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
	[cell.progressView setNeedsDisplay];
	
	cell.titleLabel.text = list.title;
	NSString *of = NSLocalizedString(@"of", nil);
	NSString *completed = NSLocalizedString(@"completed", nil);
	cell.completionLabel.text = [NSString stringWithFormat:@"%d %@ %d %@",
								 [list.completedEntries count], of, [list.entries count], completed];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.editingAccessoryType = UITableViewCellAccessoryNone;
}

@end


@implementation DOListsViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
	// eliminate separators for empty cells
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
	footer.backgroundColor = [UIColor clearColor];
	self.tableView.tableFooterView = footer;
	[footer release];
	
	// set correct separator color
	self.tableView.separatorColor = [UIColor colorWithWhite:200.0f/255.0f alpha:1.0f];

	self.fetchedResultsController = [[PDPersistenceController sharedPersistenceController] listsFetchedResultsController];
	self.fetchedResultsController.delegate = self;
	
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
	
	PDList *list = [[PDSettingsController sharedSettingsController] loadSelectedList];
	self.entriesViewController.list = list;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.entriesViewController.list) {
		NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.entriesViewController.list];
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.popoverController = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (self.popoverController.popoverVisible) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	
	if (!editing && self.entriesViewController.list) {
		NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.entriesViewController.list];
		if (indexPath) {
			[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
		}
	}
}

#pragma mark -
#pragma mark Actions

- (IBAction)addList {
	if (self.popoverController.popoverVisible) {
		return;
	}
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController beginEdits];
	PDList *list = [persistenceController createList];
	
	DOEditListViewController *controller = [[DOEditListViewController alloc] initWithList:list];
	controller.delegate = self;
	controller.title = NSLocalizedString(@"New List", nil);
	
	if ([self.delegate listsControllerShouldDisplayControllerInPopover:self]) {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
		[controller release];
		
		if (!self.popoverController) {
			self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
		} else {
			self.popoverController.contentViewController = navController;
		}
		[navController release];
		
		[self.popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
									   permittedArrowDirections:UIPopoverArrowDirectionAny
													   animated:YES];
	} else {
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
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
	[[PDPersistenceController sharedPersistenceController] moveList:list fromRow:sourceIndexPath.row toRow:destinationIndexPath.row];
	
	userIsMoving = NO;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if ([list isEqual:self.entriesViewController.list]) {
		NSInteger row = indexPath.row - 1;
		if (row < 0) row = indexPath.row + 1;
		
		if (row < [self tableView:self.tableView numberOfRowsInSection:0]) {
			NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
			PDList *list = [self.fetchedResultsController objectAtIndexPath:path];
			
			[self.delegate listsController:self didSelectList:list];
		} else {
			[self.delegate listsController:self didSelectList:nil];
		}
	}
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController deleteList:list];
	[persistenceController save];
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
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.delegate listsController:self didSelectList:list];
}

#pragma mark -
#pragma mark Edit List Delegate Methods

// Called when the user hits the save button in the popover.
- (void)editListController:(DOEditListViewController *)controller listDidChange:(PDList *)list {
	[[PDPersistenceController sharedPersistenceController] saveEdits];
	[self.popoverController dismissPopoverAnimated:YES];
	
	NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:list];
	[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self.delegate listsController:self didSelectList:list];
	
	[self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)editListController:(DOEditListViewController *)controller listDidNotChange:(PDList *)list {
	[[PDPersistenceController sharedPersistenceController] cancelEdits];
	
	if (!self.editing) {
		NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.entriesViewController.list];
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}

	[self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (userIsMoving)
		return;
	
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (userIsMoving)
		return;
	
	[self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
			if (self.entriesViewController.list) {
				NSIndexPath *indexPath = [controller indexPathForObject:self.entriesViewController.list];
				[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			}
			
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							  withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(PDListTableCell *) [self.tableView cellForRowAtIndexPath:indexPath]
					   withList:anObject];
			break;
		case NSFetchedResultsChangeMove:
			if (!userIsMoving) {
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
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
	self.fetchedResultsController = nil;
	self.popoverController = nil;
	[super dealloc];
}

@end
