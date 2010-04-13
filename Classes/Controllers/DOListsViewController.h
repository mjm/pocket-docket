@class PDPersistenceController;

@interface DOListsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	PDPersistenceController *persistenceController;
	NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) PDPersistenceController *persistenceController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (IBAction)addList;

@end
