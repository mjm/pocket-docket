#import "PDEntriesViewController.h"

#import "../PDPersistenceController.h"
#import "../Models/PDList.h"

@implementation PDEntriesViewController

@synthesize list, persistenceController, fetchedResultsController;

#pragma mark -
#pragma mark Initializing a View Controller

- (id)initWithList:(PDList *)aList persistenceController:(PDPersistenceController *)controller {
	if (![super initWithNibName:@"PDEntriesView" bundle:nil])
		return nil;
	
	self.list = aList;
	self.persistenceController = controller;
	self.fetchedResultsController = [self.persistenceController entriesFetchedResultsControllerForList:self.list];
	
	return self;
}

#pragma mark -
#pragma mark View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.list.title;
	
	NSError *error;
	[self.fetchedResultsController performFetch:&error];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.list = nil;
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
    [super dealloc];
}

@end
