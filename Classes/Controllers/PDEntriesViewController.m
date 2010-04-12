#import "PDEntriesViewController.h"

#import "../PDPersistenceController.h"
#import "../Models/PDList.h"
#import "../Models/PDListEntry.h"
#import "../Controllers/PDEntryDetailViewController.h"
#import "../Views/PDEntryTableCell.h"

#pragma mark Private Methods

@interface PDEntriesViewController (PrivateMethods)

- (void)configureCell:(PDEntryTableCell *)cell withEntry:(PDListEntry *)entry;
- (void)scrollToBottom;
- (void)displayEntryDetailsForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PDEntriesViewController (PrivateMethods)

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
}

- (void)scrollToBottom {
	NSUInteger numRows = [self tableView:self.table numberOfRowsInSection:0];
	if (numRows > 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numRows - 1) inSection:0];
		
		[self.table scrollToRowAtIndexPath:indexPath
						  atScrollPosition:UITableViewScrollPositionBottom
								  animated:YES];
	}
}

- (void)displayEntryDetailsForIndexPath:(NSIndexPath *)indexPath {
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	PDEntryDetailViewController *detailController = [[PDEntryDetailViewController alloc] initWithEntry:entry
																				 persistenceController:self.persistenceController];
	[self.navigationController pushViewController:detailController animated:YES];
	
	[detailController release];
}

@end

#pragma mark -

@implementation PDEntriesViewController

@synthesize list, persistenceController, fetchedResultsController, keyboardObserver;
@synthesize table, newEntryField;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithList:(PDList *)aList persistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDEntriesView" bundle:nil])
		return nil;
	
	self.list = aList;
	self.persistenceController = controller;
	self.fetchedResultsController = [self.persistenceController entriesFetchedResultsControllerForList:self.list];
	self.fetchedResultsController.delegate = self;
	self.keyboardObserver = [[PDKeyboardObserver alloc] initWithViewController:self delegate:self];
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.list.title;
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([UISwipeGestureRecognizer class] != nil) {
		id gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																						   action:@selector(swipeDetected:)];
		[gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight];
		[self.table addGestureRecognizer:gestureRecognizer];
	}
#endif
#endif
	
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[keyboardObserver registerNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[keyboardObserver unregisterNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ![keyboardObserver isKeyboardShowing];
}

- (void)viewDidUnload {
	self.table = nil;
	self.newEntryField = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.table setEditing:editing animated:animated];
	
	// Only do this when editing since showing the keyboard will set editing to NO
	if (editing) {
		[self.newEntryField resignFirstResponder];
	}
}

#pragma mark -
#pragma mark Keyboard Observer Delegate Methods

- (void)keyboardObserverWillShowKeyboard:(PDKeyboardObserver *)observer {
	[self scrollToBottom];
	[self setEditing:NO animated:YES];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *EntryCell = @"EntryCell";
	
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	PDEntryTableCell *cell = (PDEntryTableCell *) [tableView dequeueReusableCellWithIdentifier:EntryCell];
	
	if (cell == nil) {
		cell = [PDEntryTableCell entryTableCell];
		[cell.checkboxButton addTarget:self
								action:@selector(checkedBox:forEvent:)
					  forControlEvents:UIControlEventTouchUpInside];
	}
	
	[self configureCell:cell withEntry:entry];
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
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
	return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.table isEditing]) {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	entry.checked = [NSNumber numberWithBool:![entry.checked boolValue]];
	[self.persistenceController save];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self displayEntryDetailsForIndexPath:indexPath];
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
			[self configureCell:(PDEntryTableCell *) [self.table cellForRowAtIndexPath:indexPath]
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
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self addListEntry];
	
	return NO;
}

#pragma mark -
#pragma mark Actions

- (IBAction)addListEntry {
	NSString *text = self.newEntryField.text;
	
	if ([text length] != 0) {
		[self.persistenceController createEntry:text inList:self.list];
		self.newEntryField.text = @"";
		
		[self.newEntryField resignFirstResponder];
	}
}

- (IBAction)checkedBox:(id)sender forEvent:(UIEvent *)event {
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:location];
	if (indexPath != nil) {
		PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
		entry.checked = [NSNumber numberWithBool:![entry.checked boolValue]];
		[self.persistenceController save];
	}
}

- (IBAction)swipeDetected:(id)gestureRecognizer {
	CGPoint point = [gestureRecognizer locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:point];
	
	if (indexPath != nil) {
		PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
		entry.checked = [NSNumber numberWithBool:![entry.checked boolValue]];
		[self.persistenceController save];
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
	self.keyboardObserver = nil;
	self.table = nil;
	self.newEntryField = nil;
    [super dealloc];
}

@end
