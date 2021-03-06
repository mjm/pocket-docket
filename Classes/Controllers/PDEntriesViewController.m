#import "PDEntriesViewController.h"

#import "PDEntryDetailViewController.h"
#import "PDImportEntriesViewController.h"
#import "../Singletons/PDPersistenceController.h"
#import "../Singletons/PDSettingsController.h"
#import "PDList.h"
#import "PDListEntry.h"
#import "../Views/PDEntryTableCell.h"
#import "PDSyncController.h"


#pragma mark Private Methods

@interface PDEntriesViewController ()

- (void)configureCell:(PDEntryTableCell *)cell withEntry:(PDListEntry *)entry;
- (void)scrollToBottom;
- (void)displayEntryDetailsForIndexPath:(NSIndexPath *)indexPath;

- (void)showAddButton;
- (void)showSendButton;

@end


@implementation PDEntriesViewController

- (void)configureCell:(PDEntryTableCell *)cell withEntry:(PDListEntry *)entry
{
	cell.entryLabel.text = entry.text;

	if ([entry.checked boolValue])
	{
		cell.checkboxImage.image = [UIImage imageNamed:@"CheckBoxChecked.png"];
		cell.entryLabel.textColor = [UIColor lightGrayColor];
	}
	else
	{
		cell.checkboxImage.image = [UIImage imageNamed:@"CheckBox.png"];
		cell.entryLabel.textColor = [UIColor blackColor];
	}
	cell.entryLabel.highlightedTextColor = cell.entryLabel.textColor;
}

- (void)scrollToBottom
{
	NSUInteger numRows = [self.entriesController tableView:self.table numberOfRowsInSection:0];
	if (numRows > 0)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numRows - 1) inSection:0];
		
		[self.table scrollToRowAtIndexPath:indexPath
						  atScrollPosition:UITableViewScrollPositionBottom
								  animated:YES];
	}
}

- (void)displayEntryDetailsForIndexPath:(NSIndexPath *)indexPath
{
	PDListEntry *entry = [self.entriesController entryAtIndexPath:indexPath];
	
	PDEntryDetailViewController *detailController = [[PDEntryDetailViewController alloc] initWithEntry:entry];
	[self.navigationController pushViewController:detailController animated:YES];
	
	[detailController release];
}


#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithList:(PDList *)aList
{
	if (![super initWithNibName:@"PDEntriesView" bundle:nil])
		return nil;
	
	self.list = aList;
	self.keyboardObserver = [PDKeyboardObserver keyboardObserverWithViewController:self delegate:self];
	
	return self;
}


#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = self.list.title;
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	
	UIColor *sepColor = [UIColor colorWithRed:151.0/255.0 green:199.0/255.0 blue:223.0/255.0 alpha:1.0];
	self.table.separatorColor = sepColor;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (version >= 3.2)
	{
		id gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																		 action:@selector(swipeDetected:)];
		[gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight];
		[self.table addGestureRecognizer:gestureRecognizer];
		[gestureRecognizer release];
	}
#endif
#endif
	
	self.entriesController.list = self.list;
	[self.entriesController loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.keyboardObserver registerNotifications];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncDidStart:)
												 name:PDSyncDidStartNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncDidStop:)
												 name:PDSyncDidStopNotification
											   object:nil];
	
	[[PDSettingsController sharedSettingsController] saveSelectedList:self.list];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.newEntryField resignFirstResponder];
	[self showSendButton];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PDSyncDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PDSyncDidStopNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

	[self.keyboardObserver unregisterNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return ![self.keyboardObserver isKeyboardShowing];
	return YES;
}

- (void)viewDidUnload
{
    NSLog(@"Unloading view");
	self.entriesController = nil;
	self.table = nil;
	self.toolbar = nil;
	self.newEntryField = nil;
	self.addButton = nil;
	self.sendButton = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.table setEditing:editing animated:animated];
	
	// Only do this when editing since showing the keyboard will set editing to NO
	if (editing)
	{
		[self.newEntryField resignFirstResponder];
		[self showSendButton];
	}
}

- (BOOL)shouldPresentLoginViewController
{
	return YES;
}

- (void)applicationDidEnterBackground:(NSNotification *)note
{
    [self.newEntryField resignFirstResponder];
}


#pragma mark -
#pragma mark Changing the Button

- (void)showAddButton
{
	if ([[self.toolbar items] lastObject] == self.sendButton)
	{
		CGRect bounds = self.newEntryField.bounds;
		bounds.size.width += 10;
		self.newEntryField.bounds = bounds;
		
		NSMutableArray *items = [[self.toolbar items] mutableCopy];
		[items replaceObjectAtIndex:([items count] - 1) withObject:self.addButton];
		[self.toolbar setItems:items animated:YES];
		[items release];
	}
}

- (void)showSendButton
{
	if ([[self.toolbar items] lastObject] == self.addButton)
	{
		CGRect bounds = self.newEntryField.bounds;
		bounds.size.width -= 10;
		self.newEntryField.bounds = bounds;
		
		NSMutableArray *items = [[self.toolbar items] mutableCopy];
		[items replaceObjectAtIndex:([items count] - 1) withObject:self.sendButton];
		[self.toolbar setItems:items animated:YES];
		[items release];
	}
}

- (void)syncDidStart:(NSNotification *)note
{
	[self.entriesController beginSyncing];
}

- (void)syncDidStop:(NSNotification *)note
{
	[self.entriesController endSyncing];
}


#pragma mark -
#pragma mark Keyboard Observer Delegate Methods

- (void)keyboardObserverWillShowKeyboard:(PDKeyboardObserver *)observer {
	[self scrollToBottom];
	[self setEditing:NO animated:YES];
	
	[self showAddButton];
}


#pragma mark -
#pragma mark Import Entries Controller Delegate Methods

- (void)dismissImportEntriesController:(PDImportEntriesViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Entries Controller Delegate Methods

- (UITableViewCell *)cellForEntriesController:(PDEntriesController *)controller
{
	static NSString *EntryCell = @"EntryCell";
	
	PDEntryTableCell *cell = (PDEntryTableCell *) [self.table dequeueReusableCellWithIdentifier:EntryCell];
	if (cell == nil)
	{
		cell = [PDEntryTableCell entryTableCell];
		[cell.checkboxButton addTarget:self
								action:@selector(checkedBox:forEvent:)
					  forControlEvents:UIControlEventTouchUpInside];
	}
	
	return cell;
}

- (void)entriesController:(PDEntriesController *)controller
			configureCell:(UITableViewCell *)cell
				withEntry:(PDListEntry *)entry
{
	[self configureCell:(PDEntryTableCell *)cell withEntry:entry];
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.table.editing)
	{
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self displayEntryDetailsForIndexPath:indexPath];
}


#pragma mark -
#pragma mark Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self addListEntry];
	[textField resignFirstResponder];
	[self showSendButton];
	
	return NO;
}


#pragma mark -
#pragma mark Mail Compose Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (![MFMailComposeViewController canSendMail])
	{
		buttonIndex++;
	}
	
	if (buttonIndex == 0)
	{
		[self emailList];
	}
	else if (buttonIndex == 1)
	{
		[self importEntries];
	}
}


#pragma mark -
#pragma mark Actions

- (IBAction)addListEntry
{
	NSString *text = self.newEntryField.text;
	
	if ([text length] != 0)
	{
		[[PDPersistenceController sharedPersistenceController] createEntry:text inList:self.list];
        [[PDPersistenceController sharedPersistenceController] save];
		self.newEntryField.text = @"";
		
		[self scrollToBottom];
	}
}

- (IBAction)showActionMenu
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil, nil]; // fix for LLVM 2.0 issue
	
	if ([MFMailComposeViewController canSendMail])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Email List", nil)];
	}
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Import Entries", nil)];
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)emailList
{
	NSString *entriesText = [self.list plainTextString];
	
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
		mailController.mailComposeDelegate = self;
		[mailController setSubject:self.list.title];
		[mailController setMessageBody:entriesText isHTML:NO];
		[self presentModalViewController:mailController animated:YES];
	}
}

- (IBAction)importEntries
{
	PDImportEntriesViewController *importController = [[PDImportEntriesViewController alloc] initWithList:self.list];
	importController.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:importController];
	[importController release];
	
	[self presentModalViewController:navController animated:YES];
	[navController release];
}

- (IBAction)checkedBox:(id)sender forEvent:(UIEvent *)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:location];
	[self.entriesController checkEntryAtIndexPath:indexPath];
}

- (IBAction)swipeDetected:(id)gestureRecognizer
{
	CGPoint point = [gestureRecognizer locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:point];
	[self.entriesController checkEntryAtIndexPath:indexPath];
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.list = nil;
	self.entriesController = nil;
	self.keyboardObserver = nil;
	self.table = nil;
	self.toolbar = nil;
	self.newEntryField = nil;
	self.addButton = nil;
	self.sendButton = nil;
    [super dealloc];
}

@end
