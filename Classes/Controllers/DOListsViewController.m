#import "DOListsViewController.h"

#import "DOEntriesViewController.h"
#import "DOEditListViewController.h"
#import "../Singletons/PDPersistenceController.h"
#import "../Singletons/PDSettingsController.h"
#import "../Views/PDListTableCell.h"
#import "../Views/PDListProgressView.h"
#import "PDList.h"
#import "PDSyncController.h"

@interface DOListsViewController (PrivateMethods)

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list;
- (void)showRefreshButton:(UIBarButtonItem *)button;

@end

@implementation DOListsViewController (PrivateMethods)

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list
{
	if ([list.entries count] == 0)
	{
		cell.progressView.progress = 0.0;
	}
	else
	{
		cell.progressView.progress = ((CGFloat) [list.completedEntries count]) / ((CGFloat) [list.allEntries count]);
	}
	[cell.progressView setNeedsDisplay];
	
	cell.titleLabel.text = list.title;
	NSString *of = NSLocalizedString(@"of", nil);
	NSString *completed = NSLocalizedString(@"completed", nil);
	cell.completionLabel.text = [NSString stringWithFormat:@"%d %@ %d %@",
								 [list.completedEntries count], of, [list.allEntries count], completed];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.editingAccessoryType = UITableViewCellAccessoryNone;
}

- (void)showRefreshButton:(UIBarButtonItem *)button
{
	self.toolbarItems = [NSArray arrayWithObject:button];
}

@end


@implementation DOListsViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
	// eliminate separators for empty cells
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
	footer.backgroundColor = [UIColor clearColor];
	self.tableView.tableFooterView = footer;
	[footer release];
	
	// set correct separator color
	self.tableView.separatorColor = [UIColor colorWithWhite:200.0f/255.0f alpha:1.0f];

	self.listsController.showSelection = YES;
    
    if ([[PDSettingsController sharedSettingsController] isFirstLaunch])
	{
		UIAlertView *syncAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sync with DocketAnywhere", nil)
															message:NSLocalizedString(@"Sync Prompt Message", nil)
														   delegate:self.listsController
												  cancelButtonTitle:NSLocalizedString(@"Don't Sync", nil)
												  otherButtonTitles:NSLocalizedString(@"Sync Lists", nil), nil];
		[syncAlert show];
		[syncAlert release];
		
		[PDSettingsController sharedSettingsController].firstLaunch = NO;
	}
    
	[self.listsController loadData];
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
    
    [self showRefreshButton:[[PDPersistenceController sharedPersistenceController] isSyncing] ? self.stopButton : self.refreshButton];
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Make sure the correct list is selected when the application loads.
	[self.listsController updateViewForCurrentSelection];
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
	self.refreshButton = nil;
	self.stopButton = nil;
	self.listsController = nil;
	self.popoverController = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.listsController setEditing:editing];
	
	if (self.popoverController.popoverVisible)
	{
		[self.popoverController dismissPopoverAnimated:YES];
	}
}


#pragma mark -
#pragma mark Actions

- (IBAction)addList
{
	if (self.popoverController.popoverVisible)
	{
		return;
	}
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController beginEdits];
	PDList *list = [persistenceController createList];
	
	DOEditListViewController *controller = [[DOEditListViewController alloc] initWithList:list];
	controller.delegate = self;
	controller.title = NSLocalizedString(@"New List", nil);
	
	if ([self.delegate listsControllerShouldDisplayControllerInPopover:self])
	{
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
		[controller release];
		
		if (!self.popoverController)
		{
			self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
		}
		else
		{
			self.popoverController.contentViewController = navController;
		}
		[navController release];
		
		[self.popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
									   permittedArrowDirections:UIPopoverArrowDirectionAny
													   animated:YES];
	}
	else
	{
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

- (IBAction)refreshLists
{
	[[PDPersistenceController sharedPersistenceController] refresh];
}

- (IBAction)stopRefreshing
{
	
}

- (void)syncDidStart:(NSNotification *)note
{
    [self showRefreshButton:self.stopButton];
    [self.listsController beginSyncing];
}

- (void)syncDidStop:(NSNotification *)note
{
    [self.listsController endSyncing];
	[self showRefreshButton:self.refreshButton];
}


#pragma mark -
#pragma mark Lists Controller Delegate Methods

- (UITableViewCell *)cellForListsController:(PDListsController *)controller
{
	static NSString *ListCell = @"ListCell";
	
	PDListTableCell *cell = (PDListTableCell *) [self.tableView dequeueReusableCellWithIdentifier:ListCell];
	if (!cell)
	{
		cell = [PDListTableCell listTableCell];
	}
	
	return cell;
}

- (void)listsController:(PDListsController *)controller
		  configureCell:(UITableViewCell *)cell
			   withList:(PDList *)list
{
	[self configureCell:(PDListTableCell *)cell withList:list];
}

- (void)listsController:(PDListsController *)controller didSelectList:(PDList *)list
{
    [[PDSettingsController sharedSettingsController] saveSelectedList:list];
}


#pragma mark -
#pragma mark Edit List Delegate Methods

// Called when the user hits the save button in the popover.
- (void)editListController:(DOEditListViewController *)controller listDidChange:(PDList *)list
{
	[[PDPersistenceController sharedPersistenceController] saveEdits];
	[self.popoverController dismissPopoverAnimated:YES];
	
	self.listsController.selection = list;
	
	[self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)editListController:(DOEditListViewController *)controller listDidNotChange:(PDList *)list
{
	[[PDPersistenceController sharedPersistenceController] cancelEdits];
	[self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.refreshButton = nil;
	self.stopButton = nil;
	self.listsController = nil;
	self.popoverController = nil;
	[super dealloc];
}

@end
