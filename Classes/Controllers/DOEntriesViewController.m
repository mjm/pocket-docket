#import "DOEntriesViewController.h"

#import "../Models/PDList.h"

@implementation DOEntriesViewController

@synthesize list, popoverController, toolbar;

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
	self.toolbar = nil;
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
	
	UINavigationController *navController = (UINavigationController *) aViewController;
	navController.visibleViewController.navigationItem.rightBarButtonItem.enabled = NO;
	
	self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	NSMutableArray *toolbarItems = [toolbar.items mutableCopy];
	[toolbarItems removeObjectAtIndex:0];
	[toolbar setItems:toolbarItems animated:YES];
	[toolbarItems release];
	
	UINavigationController *navController = (UINavigationController *) aViewController;
	navController.visibleViewController.navigationItem.rightBarButtonItem.enabled = YES;
	
	self.popoverController = nil;
}

- (void)dealloc {
	self.list = nil;
	self.popoverController = nil;
	self.toolbar = nil;
	[super dealloc];
}


@end
