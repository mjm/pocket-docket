#import "DOEntriesViewController.h"

#import "../PDPersistenceController.h"
#import "../Models/PDList.h"
#import "../Models/PDListEntry.h"
#import "../Views/DOEntryTableCell.h"
#import "../Categories/NSString+Additions.h"

#pragma mark -
#pragma mark Private Methods

@interface DOEntriesViewController ()

- (void)configureCell:(DOEntryTableCell *)cell withEntry:(PDListEntry *)entry;
- (void)editEntryAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DOEntriesViewController

@synthesize list, persistenceController, fetchedResultsController;
@synthesize listsPopoverController, popoverController;
@synthesize listsViewController, toolbar, titleButton, editButton, addButton, table;
@synthesize tapGestureRecognizer;

- (void)configureCell:(DOEntryTableCell *)cell withEntry:(PDListEntry *)entry {
	[cell.checkboxButton setImage:[entry.checked boolValue] ?
	 [UIImage imageNamed:@"CheckBoxChecked.png"] :
	 [UIImage imageNamed:@"CheckBox.png"]
						 forState:UIControlStateNormal];
	cell.textLabel.text = entry.text;
	cell.commentLabel.text = entry.comment;
	
	if ([entry.checked boolValue]) {
		cell.textLabel.textColor = cell.commentLabel.textColor = [UIColor lightGrayColor];
	} else {
		cell.textLabel.textColor = cell.commentLabel.textColor = [UIColor blackColor];
	}
	cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
	cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)editEntryAtIndexPath:(NSIndexPath *)indexPath {
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.persistenceController.undoManager beginUndoGrouping];
	
	DOEntryDetailsViewController *controller = [[DOEntryDetailsViewController alloc] initWithExistingEntry:entry
																								  delegate:self];
	
	[controller presentModalToViewController:self];
	[controller release];
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSMutableArray *items = [[toolbar items] mutableCopy];
	[items insertObject:[self editButtonItem] atIndex:0];
	[toolbar setItems:items animated:NO];
	[items release];
	
	[[self editButtonItem] setEnabled:NO];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetected:)];
	swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
	[self.table addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];
	
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapDetected:)];
	tapGestureRecognizer.numberOfTapsRequired = 2;
	[self.table addGestureRecognizer:tapGestureRecognizer];
	
	[self addObserver:self
		   forKeyPath:@"list.title"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.listsPopoverController = nil;
	self.popoverController = nil;
	self.listsViewController = nil;
	self.toolbar = nil;
	self.titleButton = nil;
	self.editButton = nil;
	self.addButton = nil;
	self.table = nil;
	self.tapGestureRecognizer = nil;
	
	[self removeObserver:self forKeyPath:@"list.title"];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.table setEditing:editing animated:animated];
	self.tapGestureRecognizer.enabled = !editing;
}

#pragma mark -
#pragma mark Changing the Selected List

- (void)setList:(PDList *)aList {
	if (list != aList) {
		[list release];
		list = [aList retain];
		
		if (self.list) {
			self.fetchedResultsController = [self.persistenceController entriesFetchedResultsControllerForList:self.list];
			self.fetchedResultsController.delegate = self;
			
			NSError *error;
			[self.fetchedResultsController performFetch:&error];
			[self.table reloadData];
			
			self.editButton.enabled = YES;
			self.addButton.enabled = YES;
			[[self editButtonItem] setEnabled:YES];
		} else {
			self.editButton.enabled = NO;
			self.addButton.enabled = NO;
			[[self editButtonItem] setEnabled:NO];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if ([keyPath isEqual:@"list.title"]) {
		if (self.listsPopoverController) {
			self.titleButton.title = [change objectForKey:NSKeyValueChangeNewKey];
		}
	}
}

#pragma mark -
#pragma mark Actions

- (IBAction)editList {
	DOEditListViewController *controller = [[DOEditListViewController alloc] initWithList:self.list];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	
	if (self.listsPopoverController.popoverVisible) {
		[self.listsPopoverController dismissPopoverAnimated:YES];
	}
	
	if (self.popoverController) {
		self.popoverController.contentViewController = navController;
	} else {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
		self.popoverController.delegate = self;
	}
	[navController release];
	
	[self.popoverController presentPopoverFromBarButtonItem:self.editButton
								   permittedArrowDirections:UIPopoverArrowDirectionAny
												   animated:YES];
}

- (IBAction)addEntry {
	if (self.listsPopoverController.popoverVisible) {
		[self.listsPopoverController dismissPopoverAnimated:NO];
	}
	
	if (self.popoverController.popoverVisible) {
		[self.popoverController dismissPopoverAnimated:NO];
	}
	
	[self.persistenceController.undoManager beginUndoGrouping];
	PDListEntry *entry = [self.persistenceController createEntry:@"" inList:self.list];
	
	DOEntryDetailsViewController *controller = [[DOEntryDetailsViewController alloc] initWithNewEntry:entry delegate:self];
	[controller presentModalToViewController:self];
	[controller release];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *Cell = @"EntryCell";
	
	DOEntryTableCell *cell = (DOEntryTableCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
	if (!cell) {
		cell = [DOEntryTableCell entryTableCell];
		[cell.checkboxButton addTarget:self
								action:@selector(checkedBox:forEvent:)
					  forControlEvents:UIControlEventTouchUpInside];
	}
	
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self configureCell:cell withEntry:entry];
	
	return cell;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.persistenceController deleteEntry:entry];
	[self.persistenceController save];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toIndexPath:(NSIndexPath *)destinationIndexPath {
	userIsMoving = YES;
	
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
	[self.persistenceController moveEntry:entry fromRow:sourceIndexPath.row toRow:destinationIndexPath.row];
	
	userIsMoving = NO;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.editing) {
		return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self editEntryAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	NSString *text = entry.comment;
	
	if (!text || [text length] == 0) {
		return 44.0f;
	} else {
		CGFloat height = [text heightWithFont:[UIFont systemFontOfSize:17.0]
						   constrainedToWidth:self.table.frame.size.width - ENTRY_CELL_OFFSET];
		return 50.0f + height;
	}
}

#pragma mark -
#pragma mark Gesture Recognition

- (void)swipeDetected:(UISwipeGestureRecognizer *)gestureRecognizer {
	CGPoint point = [gestureRecognizer locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:point];
	
	if (indexPath != nil) {
		PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
		entry.checked = [NSNumber numberWithBool:![entry.checked boolValue]];
		
		// make sure the list view gets updated
		[self.persistenceController.managedObjectContext refreshObject:entry.list mergeChanges:YES];
		[self.persistenceController save];
	}
}

- (void)doubleTapDetected:(UITapGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		CGPoint popoverPoint = [gestureRecognizer locationInView:self.table];
		NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:popoverPoint];
		if (indexPath) {
			[self editEntryAtIndexPath:indexPath];
		}
	}
}

- (void)checkedBox:(id)sender forEvent:(UIEvent *)event {
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:location];
	if (indexPath != nil) {
		PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
		entry.checked = [NSNumber numberWithBool:![entry.checked boolValue]];
		
		// make sure the list view gets updated
		[self.persistenceController.managedObjectContext refreshObject:entry.list mergeChanges:YES];
		[self.persistenceController save];
	}
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
			[self configureCell:(DOEntryTableCell *) [self.table cellForRowAtIndexPath:indexPath]
					   withEntry:anObject];
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
#pragma mark Split View Delegate Methods

- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)pc {
	barButtonItem.title = @"Lists";
	NSMutableArray *toolbarItems = [toolbar.items mutableCopy];
	[toolbarItems insertObject:barButtonItem atIndex:0];
	[toolbar setItems:toolbarItems animated:YES];
	[toolbarItems release];
	
	self.titleButton.title = self.list.title;
	
	self.listsPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	NSMutableArray *toolbarItems = [toolbar.items mutableCopy];
	[toolbarItems removeObjectAtIndex:0];
	[toolbar setItems:toolbarItems animated:YES];
	[toolbarItems release];
	
	self.titleButton.title = @"";
	
	UINavigationController *controller = (UINavigationController *) aViewController;
	[controller popToRootViewControllerAnimated:NO];
	
	self.listsPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc
		  popoverController:(UIPopoverController *)pc
  willPresentViewController:(UIViewController *)aViewController {
	if (self.popoverController.popoverVisible) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	
	self.listsPopoverController.popoverContentSize = CGSizeMake(320, 1100);
	
	UINavigationController *controller = (UINavigationController *) aViewController;
	[controller popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Lists Delegate Methods

- (void)listsController:(DOListsViewController *)controller didSelectList:(PDList *)aList {
	self.list = aList;
	[self.persistenceController saveSelectedList:self.list];
	
	if (self.listsPopoverController) {
		[self.listsPopoverController dismissPopoverAnimated:YES];
	}
}

- (BOOL)listsControllerShouldDisplayControllerInPopover:(DOListsViewController *)controller {
	BOOL usePopover = self.listsPopoverController == nil;
	
	if (!usePopover) {
		self.listsPopoverController.popoverContentSize = CGSizeMake(320, 100);
	}
	
	return usePopover;
}

#pragma mark -
#pragma mark Entry Details Delegate Methods

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller
				  didSaveEntry:(PDListEntry *)entry {
	[self.persistenceController.undoManager endUndoGrouping];
	[self.persistenceController save];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller
				didCancelEntry:(PDListEntry *)entry {
	[self.persistenceController.undoManager endUndoGrouping];
	[self.persistenceController.undoManager undo];
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Edit List Delegate Methods

- (void)editListController:(DOEditListViewController *)controller listDidChange:(PDList *)list {
	[self.persistenceController save];
	
	[self.popoverController dismissPopoverAnimated:YES];
	self.popoverController = nil;
}

#pragma mark -
#pragma mark Popover Controller Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.popoverController = nil;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
	self.listsPopoverController = nil;
	self.popoverController = nil;
	self.listsViewController = nil;
	self.toolbar = nil;
	self.titleButton = nil;
	self.editButton = nil;
	self.addButton = nil;
	self.table = nil;
	self.tapGestureRecognizer = nil;
	[super dealloc];
}


@end
