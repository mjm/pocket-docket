#import "DOEntriesViewController.h"

#import "../Singletons/PDPersistenceController.h"
#import "../Singletons/PDSettingsController.h"
#import "PDList.h"
#import "PDListEntry.h"
#import "../Views/DOEntryTableCell.h"
#import "../Categories/NSString+Additions.h"
#import "PDSyncController.h"

#pragma mark -
#pragma mark Private Methods

@interface DOEntriesViewController ()

- (void)configureCell:(DOEntryTableCell *)cell withEntry:(PDListEntry *)entry;
- (void)editEntryAtIndexPath:(NSIndexPath *)indexPath;
- (void)dismissPopovers:(BOOL)animated;

@end

@implementation DOEntriesViewController

- (void)configureCell:(DOEntryTableCell *)cell withEntry:(PDListEntry *)entry
{
	cell.entryLabel.text = entry.text;
	cell.commentLabel.text = entry.comment;
	
	if ([entry.checked boolValue])
	{
		cell.checkboxImage.image = [UIImage imageNamed:@"CheckBoxChecked.png"];
		cell.entryLabel.textColor = cell.commentLabel.textColor = [UIColor lightGrayColor];
	}
	else
	{
		cell.checkboxImage.image = [UIImage imageNamed:@"CheckBox.png"];
		cell.entryLabel.textColor = cell.commentLabel.textColor = [UIColor blackColor];
	}
	cell.entryLabel.highlightedTextColor = cell.entryLabel.textColor;
	cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)editEntryAtIndexPath:(NSIndexPath *)indexPath
{
	PDListEntry *entry = [self.entriesController entryAtIndexPath:indexPath];
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

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIColor *sepColor = [UIColor colorWithRed:151.0/255.0 green:199.0/255.0 blue:223.0/255.0 alpha:1.0];
	self.table.separatorColor = sepColor;
	
	NSMutableArray *items = [[self.toolbar items] mutableCopy];
	[items insertObject:[self editButtonItem] atIndex:0];
	[self.toolbar setItems:items animated:NO];
	[items release];
	
	//[[self editButtonItem] setEnabled:NO];
	
	self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																			action:@selector(swipeDetected:)];
	self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
	[self.table addGestureRecognizer:self.swipeGestureRecognizer];
	
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapDetected:)];
	self.tapGestureRecognizer.numberOfTapsRequired = 2;
	[self.table addGestureRecognizer:self.tapGestureRecognizer];
	
	[self.entriesController bindToListsController:self.listsController];
	
	[self.listsController addObserver:self
						   forKeyPath:@"selection.title"
							  options:NSKeyValueObservingOptionNew
							  context:NULL];
	[self.listsController addObserver:self
						   forKeyPath:@"selection"
							  options:NSKeyValueObservingOptionNew
							  context:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncDidStart:)
												 name:PDSyncDidStartNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncDidStop:)
												 name:PDSyncDidStopNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PDSyncDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PDSyncDidStopNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[self.listsController removeObserver:self forKeyPath:@"selection.title"];
	[self.listsController removeObserver:self forKeyPath:@"selection"];
	
	self.listsController = nil;
	self.entriesController = nil;
	self.listsPopoverController = nil;
	self.popoverController = nil;
	self.toolbar = nil;
	self.titleButton = nil;
	self.editButton = nil;
	self.addButton = nil;
	self.table = nil;
	self.tapGestureRecognizer = nil;
	self.swipeGestureRecognizer = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.table setEditing:editing animated:animated];
	
	self.swipeGestureRecognizer.enabled = !editing;
	self.tapGestureRecognizer.enabled = !editing;
}

- (BOOL)shouldPresentLoginViewController
{
	return YES;
}

#pragma mark -
#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if ([keyPath isEqualToString:@"selection.title"])
	{
		if (self.listsPopoverController)
		{
			id title = [change objectForKey:NSKeyValueChangeNewKey];
			
			if (![title isEqual:[NSNull null]])
			{
				self.titleButton.title = title;				
			}
			else
			{
				self.titleButton.title = @"";
			}
		}
	}
	else if ([keyPath isEqualToString:@"selection"])
	{
        if (self.listsPopoverController)
        {
            [self.listsPopoverController dismissPopoverAnimated:YES];
        }
        
		id list = [change objectForKey:NSKeyValueChangeNewKey];
		
		BOOL enable = list != [NSNull null];
		self.sendButton.enabled = enable;
		self.editButton.enabled = enable;
		self.addButton.enabled = enable;
		[self editButtonItem].enabled = enable;
	}
}


#pragma mark -
#pragma mark Actions

- (IBAction)showActionMenu
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
	
	if ([MFMailComposeViewController canSendMail])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Email List", nil)];
	}
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Import Entries", nil)];
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	
	[actionSheet showFromBarButtonItem:self.sendButton animated:YES];
	[actionSheet release];
}

- (IBAction)emailList
{
	[self dismissPopovers:NO];
	
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
		mailController.mailComposeDelegate = self;
		
		PDList *list = self.listsController.selection;
		[mailController setSubject:list.title];
		[mailController setMessageBody:[list plainTextString] isHTML:NO];
		[self presentModalViewController:mailController animated:YES];
	}
}

- (IBAction)importEntries
{
	PDImportEntriesViewController *importController = [[PDImportEntriesViewController alloc] initWithList:self.listsController.selection];
	importController.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:importController];
	[importController release];
	
	navController.modalPresentationStyle = UIModalPresentationPageSheet;
	
	[self presentModalViewController:navController animated:YES];
	[navController release];
}

- (IBAction)editList
{
	[self dismissPopovers:NO];
	
	[[PDPersistenceController sharedPersistenceController] beginEdits];
	DOEditListViewController *controller = [[DOEditListViewController alloc] initWithList:self.listsController.selection];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	
	if (self.popoverController)
	{
		self.popoverController.contentViewController = navController;
	}
	else
	{
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
		self.popoverController.delegate = self;
	}
	[navController release];
	
	[self.popoverController presentPopoverFromBarButtonItem:self.editButton
								   permittedArrowDirections:UIPopoverArrowDirectionAny
												   animated:YES];
}

- (IBAction)addEntry
{
	[self dismissPopovers:NO];
	
	[[PDPersistenceController sharedPersistenceController] beginEdits];
	
	DONewEntryViewController *controller = [[DONewEntryViewController alloc] initWithList:self.listsController.selection];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	
	if (self.popoverController)
	{
		self.popoverController.contentViewController = navController;
	}
	else
	{
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
		self.popoverController.delegate = self;
	}
	[navController release];
	
	[self.popoverController presentPopoverFromBarButtonItem:self.addButton
								   permittedArrowDirections:UIPopoverArrowDirectionAny
												   animated:YES];
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
#pragma mark Entries Controller Delegate Methods

- (UITableViewCell *)cellForEntriesController:(PDEntriesController *)controller
{
	static NSString *Cell = @"EntryCell";
	
	DOEntryTableCell *cell = (DOEntryTableCell *) [self.table dequeueReusableCellWithIdentifier:Cell];
	if (!cell)
	{
		cell = [DOEntryTableCell entryTableCell];
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
	[self configureCell:(DOEntryTableCell *)cell withEntry:entry];
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.editing ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self editEntryAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PDListEntry *entry = [self.entriesController entryAtIndexPath:indexPath];
	NSString *text = entry.comment;
	
	if (!text || [text length] == 0)
	{
		return 44.0f;
	}
	else
	{
		CGFloat height = [text heightWithFont:[UIFont systemFontOfSize:17.0]
						   constrainedToWidth:self.table.frame.size.width - ENTRY_CELL_OFFSET];
		return 50.0f + height;
	}
}


#pragma mark -
#pragma mark Gesture Recognition

- (void)swipeDetected:(UISwipeGestureRecognizer *)gestureRecognizer
{
	CGPoint point = [gestureRecognizer locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:point];
	[self.entriesController checkEntryAtIndexPath:indexPath];
}

- (void)doubleTapDetected:(UITapGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGPoint popoverPoint = [gestureRecognizer locationInView:self.table];
		NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:popoverPoint];
		if (indexPath)
		{
			[self editEntryAtIndexPath:indexPath];
		}
	}
}

- (void)checkedBox:(id)sender forEvent:(UIEvent *)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:location];
	[self.entriesController checkEntryAtIndexPath:indexPath];
}


#pragma mark -
#pragma mark Split View Delegate Methods

- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)pc
{
	barButtonItem.title = NSLocalizedString(@"Lists", nil);
	if (barButtonItem != [self.toolbar.items objectAtIndex:0])
	{
		NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
		[toolbarItems insertObject:barButtonItem atIndex:0];
		[self.toolbar setItems:toolbarItems animated:YES];
		[toolbarItems release];
	}
	
	self.titleButton.title = self.listsController.selection.title;
	
	self.listsPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
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
  willPresentViewController:(UIViewController *)aViewController
{
	if (self.popoverController.popoverVisible)
	{
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
#pragma mark Lists Delegate Methods

- (BOOL)listsControllerShouldDisplayControllerInPopover:(DOListsViewController *)controller
{
	BOOL usePopover = self.listsPopoverController == nil;
	
	if (!usePopover)
	{
		self.listsPopoverController.popoverContentSize = CGSizeMake(320, 100);
	}
	
	return usePopover;
}


#pragma mark -
#pragma mark Entry Details Delegate Methods

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller
				  didSaveEntry:(PDListEntry *)entry
{
    [[PDPersistenceController sharedPersistenceController] markChanged:entry];
	[[PDPersistenceController sharedPersistenceController] saveEdits];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)entryDetailsController:(DOEntryDetailsViewController *)controller
				didCancelEntry:(PDListEntry *)entry
{
	[[PDPersistenceController sharedPersistenceController] cancelEdits];
	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark New Entry Delegate Methods

- (void)newEntryController:(DONewEntryViewController *)controller
			didCreateEntry:(PDListEntry *)entry
			 shouldDismiss:(BOOL)dismiss
{
	if ([entry.text length] == 0)
	{
		if (dismiss)
		{
			[self newEntryController:controller didCancelEntry:entry];
		}
		return;
	}
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController saveEdits];
	
	if (dismiss)
	{
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
	}
	else
	{
		[persistenceController beginEdits];
	}
}

- (void)newEntryController:(DONewEntryViewController *)controller
			didCancelEntry:(PDListEntry *)entry
{
	[[PDPersistenceController sharedPersistenceController] cancelEdits];
	
	if (self.popoverController.popoverVisible)
	{
		[self.popoverController dismissPopoverAnimated:YES];
	}
	self.popoverController = nil;
}


#pragma mark -
#pragma mark Edit List Delegate Methods

- (void)editListController:(DOEditListViewController *)controller
			 listDidChange:(PDList *)list
{
    [[PDPersistenceController sharedPersistenceController] markChanged:list];
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
#pragma mark Import Entries Controller Delegate Methods

- (void)dismissImportEntriesController:(PDImportEntriesViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Popover Controller Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[self.listsController removeObserver:self forKeyPath:@"selection.title"];
	[self.listsController removeObserver:self forKeyPath:@"selection"];
	
	self.listsController = nil;
	self.entriesController = nil;
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
