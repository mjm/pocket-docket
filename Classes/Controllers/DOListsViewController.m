#import "DOListsViewController.h"

#import "../PDPersistenceController.h"

@implementation DOListsViewController

@synthesize persistenceController, fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	self.persistenceController = nil;
	self.fetchedResultsController = nil;
    [super dealloc];
}

@end
