#import "DOEntriesViewController.h"

#import "DOListsViewController.h"
#import "DOEditListViewController.h"
#import "DOEntryDetailsViewController.h"
#import "../PDPersistenceController.h"
#import "../Models/PDList.h"
#import "../Models/PDListEntry.h"
#import "../Views/PDEntryTableCell.h"

#pragma mark -
#pragma mark Private Methods

@interface DOEntriesViewController ()

- (void)configureCell:(PDEntryTableCell *)cell withEntry:(PDListEntry *)entry;
- (CGRect)popoverRectForEntry:(PDListEntry *)entry centeredAtPoint:(CGPoint)point;

@end

@implementation DOEntriesViewController

@synthesize list, persistenceController, fetchedResultsController, selectedEntry;
@synthesize popoverController, listsViewController, toolbar, editButton, addButton, table;

- (void)configureCell:(PDEntryTableCell *)cell withEntry:(PDListEntry *)entry {
	[cell.checkboxButton setImage:[entry.checked boolValue] ?
	 [UIImage imageNamed:@"CheckBoxChecked.png"] :
	 [UIImage imageNamed:@"CheckBox.png"]
						 forState:UIControlStateNormal];
	cell.textLabel.text = entry.text;
	
	if ([entry.checked boolValue]) {
		cell.textLabel.textColor = [UIColor lightGrayColor];
	} else {
		cell.textLabel.textColor = [UIColor blackColor];
	}
	cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
	cell.accessoryType = UITableViewCellAccessoryNone;
}

- (CGRect)popoverRectForEntry:(PDListEntry *)entry centeredAtPoint:(CGPoint)point {
	NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:entry];
	CGRect rect = [self.table rectForRowAtIndexPath:indexPath];
	return CGRectMake(point.x - 22.0f, rect.origin.y, 44.0f, rect.size.height);
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetected:)];
	swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
	[self.table addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];
	
	UILongPressGestureRecognizer *holdRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapAndHoldDetected:)];
	holdRecognizer.minimumPressDuration = 0.7;
	[self.table addGestureRecognizer:holdRecognizer];
	[holdRecognizer release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.popoverController = nil;
	self.listsViewController = nil;
	self.toolbar = nil;
	self.editButton = nil;
	self.addButton = nil;
	self.table = nil;
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
		} else {
			self.editButton.enabled = NO;
			self.addButton.enabled = NO;
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
	
	if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
	self.popoverController.delegate = self;
	[navController release];
	
	[self.popoverController presentPopoverFromBarButtonItem:self.editButton
								   permittedArrowDirections:UIPopoverArrowDirectionAny
												   animated:YES];
}

- (IBAction)addEntry {
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
	
	PDEntryTableCell *cell = (PDEntryTableCell *) [tableView dequeueReusableCellWithIdentifier:Cell];
	if (!cell) {
		cell = [PDEntryTableCell entryTableCell];
		[cell.checkboxButton addTarget:self
								action:@selector(checkedBox:forEvent:)
					  forControlEvents:UIControlEventTouchUpInside];
	}
	
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self configureCell:cell withEntry:entry];
	
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
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

- (void)tapAndHoldDetected:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		
		popoverPoint = [gestureRecognizer locationInView:self.table];
		NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:popoverPoint];
		if (indexPath) {
			self.selectedEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
			UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
															   delegate:self
													  cancelButtonTitle:nil
												 destructiveButtonTitle:nil
													  otherButtonTitles:@"Edit Entry", @"Delete Entry", nil];
			[sheet showFromRect:[self popoverRectForEntry:self.selectedEntry centeredAtPoint:popoverPoint]
						 inView:self.table
					   animated:YES];
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
//	if (userIsMoving)
//		return;
	
	[self.table beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//	if (userIsMoving)
//		return;
	
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
			[self configureCell:(PDEntryTableCell *) [self.table cellForRowAtIndexPath:indexPath]
					   withEntry:anObject];
			break;
		case NSFetchedResultsChangeMove:
//			if (!userIsMoving) {
				[self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
									  withRowAnimation:UITableViewRowAnimationFade];
				[self.table insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
									  withRowAnimation:UITableViewRowAnimationFade];
//			}
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
	
	self.listsViewController.navigationItem.rightBarButtonItem.enabled = NO;
	
	self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	NSMutableArray *toolbarItems = [toolbar.items mutableCopy];
	[toolbarItems removeObjectAtIndex:0];
	[toolbar setItems:toolbarItems animated:YES];
	[toolbarItems release];
	
	self.listsViewController.navigationItem.rightBarButtonItem.enabled = YES;
	
	self.popoverController = nil;
}

#pragma mark -
#pragma mark Entry Details Delegate Methods

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didSaveEntry:(PDListEntry *)entry {
	[self.persistenceController.undoManager endUndoGrouping];
	[self.persistenceController save];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller didCancelEntry:(PDListEntry *)entry {
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
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([actionSheet destructiveButtonIndex] == -1) {
		if (buttonIndex == 0) {
			[self.persistenceController.undoManager beginUndoGrouping];
			
			DOEntryDetailsViewController *controller = [[DOEntryDetailsViewController alloc] initWithExistingEntry:self.selectedEntry
																										  delegate:self];
			
			[controller presentModalToViewController:self];
			[controller release];
		} else if (buttonIndex == 1) {
			UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Delete Entry"
															   delegate:self
													  cancelButtonTitle:@"Cancel"
												 destructiveButtonTitle:@"Delete Entry"
													  otherButtonTitles:nil];
			[sheet showFromRect:[self popoverRectForEntry:self.selectedEntry centeredAtPoint:popoverPoint]
						 inView:self.table
					   animated:YES];
		}
	} else {
		if (buttonIndex == [actionSheet destructiveButtonIndex]) {
			[self.persistenceController deleteEntry:self.selectedEntry];
			self.selectedEntry = nil;
		}
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
	self.popoverController = nil;
	self.listsViewController = nil;
	self.toolbar = nil;
	self.editButton = nil;
	self.addButton = nil;
	self.table = nil;
	[super dealloc];
}


@end
