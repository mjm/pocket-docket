@class PDList;
@class PDListEntry;

@protocol PDEntriesControllerDelegate;

@interface PDEntriesController : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate> {
	BOOL movingEntries;
}

@property (nonatomic, assign) IBOutlet id <PDEntriesControllerDelegate> delegate;
@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)loadData;
- (void)checkEntryAtIndexPath:(NSIndexPath *)indexPath;
- (PDListEntry *)entryAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol PDEntriesControllerDelegate <NSObject>

- (UITableViewCell *)cellForEntriesController:(PDEntriesController *)controller;

- (void)entriesController:(PDEntriesController *)controller
			configureCell:(UITableViewCell *)cell
				withEntry:(PDListEntry *)entry;

@end