#import "PDListsViewController.h"

#import "PDEditListViewController.h"
#import "PDEntriesViewController.h"
#import "PDLoginViewController.h"
#import "../Singletons/PDPersistenceController.h"
#import "../Singletons/PDSettingsController.h"
#import "PDList.h"
#import "../Views/PDListTableCell.h"
#import "../Views/PDListProgressView.h"
#import "ConnectionManager.h"
#import "PDSyncController.h"


#pragma mark Private Methods

@interface PDListsViewController (PrivateMethods)

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list;
- (void)doneEditingList:(PDList *)list;
- (void)showRefreshButton:(UIBarButtonItem *)button;
- (void)resetAddFlag;

@end


@implementation PDListsViewController (PrivateMethods)

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
	cell.titleLabel.text = list.title;
	
	NSString *of = NSLocalizedString(@"of", nil);
	NSString *completed = NSLocalizedString(@"completed", nil);
	cell.completionLabel.text = [NSString stringWithFormat:@"%d %@ %d %@",
								 [list.completedEntries count], of, [list.allEntries count], completed];
}

- (void)doneEditingList:(PDList *)list
{
	if (isAdd)
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self.navigationController popViewControllerAnimated:YES];
		
		NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:list];
		[self.table deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	[[PDPersistenceController sharedPersistenceController] save];
}

- (void)showRefreshButton:(UIBarButtonItem *)button
{
	self.toolbarItems = [NSArray arrayWithObject:button];
}

- (void)resetAddFlag
{
	isAdd = NO;
}

@end

#pragma mark -

@implementation PDListsViewController


#pragma mark -
#pragma mark Initializing a View Controller

- (id)init
{
	if (![super initWithNibName:@"PDListsView" bundle:nil])
		return nil;
	
	self.title = NSLocalizedString(@"Lists", nil);
	return self;
}


#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
	self.navigationItem.rightBarButtonItem = self.addButton;
	self.toolbarItems = [NSArray arrayWithObject:self.refreshButton];
	
	// eliminate separators for empty cells
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
	footer.backgroundColor = [UIColor clearColor];
	self.table.tableFooterView = footer;
	[footer release];
	
	// set correct separator color
	self.table.separatorColor = [UIColor colorWithWhite:200.0f/255.0f alpha:1.0f];
	
	[self.listsController loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Make sure the table is not in editing mode.
	[self setEditing:NO];
	
	[[PDSettingsController sharedSettingsController] saveSelectedList:nil];
	
	self.navigationController.toolbarHidden = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncDidStart:)
												 name:PDSyncDidStartNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(syncDidStop:)
												 name:PDSyncDidStopNotification
											   object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSIndexPath *indexPath = [self.table indexPathForSelectedRow];
	if (indexPath)
	{
		[self.table deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	self.navigationController.toolbarHidden = YES;
	
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
	
	self.table = nil;
	self.addButton = nil;
	self.refreshButton = nil;
	self.stopButton = nil;
	self.backButton = nil;
	self.listsController = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.table setEditing:editing animated:animated];
}

- (BOOL)shouldPresentLoginViewController
{
	return !isAdd;
}


#pragma mark -
#pragma mark Actions

- (IBAction)addList
{
	isAdd = YES;
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController beginEdits];
	PDList *list = [persistenceController createList];
	
	PDEditListViewController *editController = [[PDEditListViewController alloc] initWithList:list];
	editController.title = NSLocalizedString(@"New List", nil);
	editController.delegate = self;
	
	[self presentModalViewController:editController animated:YES];
	[editController release];
}

- (IBAction)refreshLists
{
	[[PDPersistenceController sharedPersistenceController] save];
}

- (IBAction)stopRefreshing
{
//	[[ConnectionManager sharedInstance] cancelAllJobs];
//	[self showRefreshButton:self.refreshButton];
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)syncDidStart:(NSNotification *)note
{
	[self showRefreshButton:self.stopButton];
}

- (void)syncDidStop:(NSNotification *)note
{
	[self showRefreshButton:self.refreshButton];
}


#pragma mark -
#pragma mark Lists Controller Delegate Methods

- (UITableViewCell *)cellForListsController:(PDListsController *)controller
{
	static NSString *ListCell = @"ListCell";
	
	PDListTableCell *cell = (PDListTableCell *) [self.table dequeueReusableCellWithIdentifier:ListCell];
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

- (void)listsController:(PDListsController *)controller
		  didSelectList:(PDList *)list
{
	if (self.table.editing)
	{
		isAdd = NO;
		
		PDEditListViewController *editController = [[PDEditListViewController alloc] initWithList:list];
		editController.delegate = self;
		
		[self.navigationController pushViewController:editController animated:YES];
		[editController release];
	}
	else
	{
		PDEntriesViewController *entriesController = [[PDEntriesViewController alloc] initWithList:list];
		[self.navigationController pushViewController:entriesController animated:YES];
		[entriesController release];
	}
}


#pragma mark -
#pragma mark Edit List Controller Delegate Methods

- (void)editListController:(PDEditListViewController *)controller listDidChange:(PDList *)list
{
	// Prevent edits from crashing
	if (isAdd)
	{
		[[PDPersistenceController sharedPersistenceController] saveEdits];
	}
	else
	{
		[[PDPersistenceController sharedPersistenceController] markChanged:list];
	}
	
	[self doneEditingList:list];
	
	if (isAdd)
	{
		NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:list];
		[self.table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		
		PDEntriesViewController *entriesController = [[PDEntriesViewController alloc] initWithList:list];
		[self.navigationController pushViewController:entriesController animated:YES];
		[entriesController release];
		
		[self performSelector:@selector(resetAddFlag) withObject:nil afterDelay:1.0];
	}
}

- (void)editListController:(PDEditListViewController *)controller listDidNotChange:(PDList *)list
{
	[[PDPersistenceController sharedPersistenceController] cancelEdits];

	[self doneEditingList:list];
	
	isAdd = NO;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.table = nil;
	self.addButton = nil;
	self.refreshButton = nil;
	self.stopButton = nil;
	self.backButton = nil;
	self.fetchedResultsController = nil;
	
    [super dealloc];
}


@end
