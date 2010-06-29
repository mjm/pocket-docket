#import "DOEntriesViewController.h"

#import "../PDPersistenceController.h"
#import "../PDSettingsController.h"
#import "../Models/PDList.h"
#import "../Models/PDListEntry.h"
#import "../Views/DOEntryTableCell.h"
#import "../Categories/NSString+Additions.h"

#pragma mark -
#pragma mark Private Methods

@interface DOEntriesViewController ()

- (void)configureCell:(DOEntryTableCell *)cell withEntry:(PDListEntry *)entry;
- (void)editEntryAtIndexPath:(NSIndexPath *)indexPath;
- (void)dismissPopovers:(BOOL)animated;

@end

@implementation DOEntriesViewController

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

- (void)editEntryAtIndexPath:(NSIndexPath *)indexPath
{
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[[PDPersistenceController sharedPersistenceController] beginEdits];
	
	DOEntryDetailsViewController *controller = [[DOEntryDetailsViewController alloc] initWithEntry:entry
																						  delegate:self];
	
	[controller presentModalToViewController:self];
	[controller release];
}

- (void)dismissPopovers:(BOOL)animated
{
	if (self.listsPopoverController.popoverVisible)
	{
		[self.listsPopoverController dismissPopoverAnimated:animated];
	}
	
	if (self.popoverController.popoverVisible)
	{
		[self.popoverController dismissPopoverAnimated:animated];
	}
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIColor *sepColor = [UIColor colorWithRed:151.0/255.0 green:199.0/255.0 blue:223.0/255.0 alpha:1.0];
	self.table.separatorColor = sepColor;
	
	NSMutableArray *items = [[self.toolbar items] mutableCopy];
	[items insertObject:[self editButtonItem] atIndex:0];
	[self.toolbar setItems:items animated:NO];
	[items release];
	
	[[self editButtonItem] setEnabled:NO];
	
	self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																			action:@selector(swipeDetected:)];
	self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
	[self.table addGestureRecognizer:self.swipeGestureRecognizer];
	
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapDetected:)];
	self.tapGestureRecognizer.numberOfTapsRequired = 2;
	[self.table addGestureRecognizer:self.tapGestureRecognizer];
	
	self.sendButton.enabled = [MFMailComposeViewController canSendMail];
	
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
	self.toolbar = nil;
	self.titleButton = nil;
	self.editButton = nil;
	self.addButton = nil;
	self.table = nil;
	self.tapGestureRecognizer = nil;
	self.swipeGestureRecognizer = nil;
	
	[self removeObserver:self forKeyPath:@"list.title"];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.table setEditing:editing animated:animated];
	self.swipeGestureRecognizer.enabled = !editing;
	self.tapGestureRecognizer.enabled = !editing;
}

#pragma mark -
#pragma mark Changing the Selected List

- (void)setList:(PDList *)aList {
	if (self.list != aList) {
		[self.list release];
		list = [aList retain];
		
		if (self.list) {
			self.fetchedResultsController = [[PDPersistenceController sharedPersistenceController]
											 entriesFetchedResultsControllerForList:self.list];
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
			id title = [change objectForKey:NSKeyValueChangeNewKey];
			if (![title isEqual:[NSNull null]]) {
				self.titleButton.title = [change objectForKey:NSKeyValueChangeNewKey];				
			} else {
				self.titleButton.title = @"";
			}
		}
	}
}

#pragma mark -
#pragma mark Actions

- (IBAction)emailList {
	[self dismissPopovers:NO];
	
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;
	[mailController setSubject:self.list.title];
	[mailController setMessageBody:[self.list plainTextString] isHTML:NO];
	[self presentModalViewController:mailController animated:YES];
}

- (IBAction)editList {
	[self dismissPopovers:NO];
	
	[[PDPersistenceController sharedPersistenceController] beginEdits];
	DOEditListViewController *controller = [[DOEditListViewController alloc] initWithList:self.list];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	
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
	[self dismissPopovers:NO];
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController beginEdits];
	PDListEntry *entry = [persistenceController createEntry:@"" inList:self.list];
	
	DONewEntryViewController *controller = [[DONewEntryViewController alloc] initWithEntry:entry];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	
	if (self.popoverController) {
		self.popoverController.contentViewController = navController;
	} else {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
		self.popoverController.delegate = self;
	}
	[navController release];
	
	[self.popoverController presentPopoverFromBarButtonItem:self.addButton
								   permittedArrowDirections:UIPopoverArrowDirectionAny
												   animated:YES];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return self.editing;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController deleteEntry:entry];
	[persistenceController save];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toIndexPath:(NSIndexPath *)destinationIndexPath {
	userIsMoving = YES;
	
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
	[[PDPersistenceController sharedPersistenceController] moveEntry:entry
															 fromRow:sourceIndexPath.row
															   toRow:destinationIndexPath.row];
	
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
		PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
		[persistenceController.managedObjectContext refreshObject:entry.list mergeChanges:YES];
		[persistenceController save];
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
		PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
		[persistenceController.managedObjectContext refreshObject:entry.list mergeChanges:YES];
		[persistenceController save];
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
	barButtonItem.title = NSLocalizedString(@"Lists", nil);
	NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
	[toolbarItems insertObject:barButtonItem atIndex:0];
	[self.toolbar setItems:toolbarItems animated:YES];
	[toolbarItems release];
	
	self.titleButton.title = self.list.title;
	
	self.listsPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
	[toolbarItems removeObjectAtIndex:0];
	[self.toolbar setItems:toolbarItems animated:YES];
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
#pragma mark Mail Compose Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Lists Delegate Methods

- (void)listsController:(DOListsViewController *)controller didSelectList:(PDList *)aList {
	self.list = aList;
	[[PDSettingsController sharedSettingsController] saveSelectedList:self.list];
	
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
	[[PDPersistenceController sharedPersistenceController] saveEdits];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller
				didCancelEntry:(PDListEntry *)entry {
	[[PDPersistenceController sharedPersistenceController] cancelEdits];
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark New Entry Delegate Methods

- (void)newEntryController:(DONewEntryViewController *)controller
			didCreateEntry:(PDListEntry *)entry
			 shouldDismiss:(BOOL)dismiss {
	if ([entry.text length] == 0) {
		if (dismiss) {
			[self newEntryController:controller didCancelEntry:entry];
		}
		return;
	}
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController saveEdits];
	
	if (dismiss) {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
	} else {
		[persistenceController beginEdits];
		PDListEntry *entry = [persistenceController createEntry:@"" inList:self.list];
		controller.entry = entry;
	}
}

- (void)newEntryController:(DONewEntryViewController *)controller
			didCancelEntry:(PDListEntry *)entry {
	[[PDPersistenceController sharedPersistenceController] cancelEdits];
	
	if (self.popoverController.popoverVisible) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	self.popoverController = nil;
}

#pragma mark -
#pragma mark Edit List Delegate Methods

- (void)editListController:(DOEditListViewController *)controller
			 listDidChange:(PDList *)list
{
	[[PDPersistenceController sharedPersistenceController] saveEdits];
	
	[self.popoverController dismissPopoverAnimated:YES];
	self.popoverController = nil;
}

- (void)editListController:(DOEditListViewController *)controller
		  listDidNotChange:(PDList *)list
{
	[[PDPersistenceController sharedPersistenceController] cancelEdits];
}

#pragma mark -
#pragma mark Popover Controller Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.popoverController = nil;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"list.title"];
	self.list = nil;
	self.fetchedResultsController = nil;
	self.listsPopoverController = nil;
	self.popoverController = nil;
	self.toolbar = nil;
	self.titleButton = nil;
	self.editButton = nil;
	self.addButton = nil;
	self.table = nil;
	self.tapGestureRecognizer = nil;
	self.swipeGestureRecognizer = nil;
	[super dealloc];
}


@end
