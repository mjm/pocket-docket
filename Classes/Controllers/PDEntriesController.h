@class PDList;
@class PDListEntry;
@class PDListsController;

@protocol PDEntriesControllerDelegate;

@interface PDEntriesController : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate> {
	BOOL movingEntries;
	BOOL syncing;
}

@property (nonatomic, assign) IBOutlet id <PDEntriesControllerDelegate> delegate;
@property (nonatomic, retain) PDList *list;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) PDListsController *listsController;

- (void)loadData;
- (void)checkEntryAtIndexPath:(NSIndexPath *)indexPath;
- (PDListEntry *)entryAtIndexPath:(NSIndexPath *)indexPath;

- (void)bindToListsController:(PDListsController *)controller;

- (void)beginSyncing;
- (void)endSyncing;

@end


@protocol PDEntriesControllerDelegate <NSObject>

- (UITableViewCell *)cellForEntriesController:(PDEntriesController *)controller;

- (void)entriesController:(PDEntriesController *)controller
			configureCell:(UITableViewCell *)cell
				withEntry:(PDListEntry *)entry;

@end