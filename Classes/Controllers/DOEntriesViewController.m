#import "DOEntriesViewController.h"

#import "DOListsViewController.h"
#import "DOEditListViewController.h"
#import "DOEntryDetailsViewController.h"
#import "../PDPersistenceController.h"
#import "../Models/PDList.h"

@implementation DOEntriesViewController

@synthesize list, persistenceController;
@synthesize popoverController, listsViewController, toolbar, editButton;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
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
}

#pragma mark -
#pragma mark Changing the Selected List

- (void)setList:(PDList *)aList {
	if (list != aList) {
		[list release];
		list = [aList retain];
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
	
	DOEntryDetailsViewController *controller = [[DOEntryDetailsViewController alloc] initWithEntry:entry];
	controller.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	[controller release];
	
	[self presentModalViewController:navController animated:YES];
	[navController release];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
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
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
	self.persistenceController = nil;
	self.popoverController = nil;
	self.listsViewController = nil;
	self.toolbar = nil;
	self.editButton = nil;
	[super dealloc];
}


@end
