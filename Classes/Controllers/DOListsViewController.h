@class PDPersistenceController;

@interface DOListsViewController : UITableViewController {
	PDPersistenceController *persistenceController;
	NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
