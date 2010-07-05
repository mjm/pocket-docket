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

- (void)configureCell:(PDListTableCell *)cell withList:(PDList *)list
{
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
	[self.listsController loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Make sure the correct list is selected when the application loads.
	[self.listsController updateViewForCurrentSelection];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
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
	[self.delegate listsController:self didSelectList:list];
}


#pragma mark -
#pragma mark Edit List Delegate Methods

// Called when the user hits the save button in the popover.
- (void)editListController:(DOEditListViewController *)controller listDidChange:(PDList *)list
{
	[[PDPersistenceController sharedPersistenceController] saveEdits];
	[self.popoverController dismissPopoverAnimated:YES];
	
	self.listsController.selection = list;
	// TODO remove
	[self.delegate listsController:self didSelectList:list];
	
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
	self.listsController = nil;
	self.popoverController = nil;
	[super dealloc];
}

@end
