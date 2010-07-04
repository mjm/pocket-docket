@class PDList;
@class PDListsController;

@protocol PDListsControllerDelegate;


@interface PDListsController : NSObject <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	BOOL movingList;
}

@property (nonatomic, assign) IBOutlet id <PDListsControllerDelegate> delegate;
@property (nonatomic, retain) PDList *selection;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)loadData;

@end


@protocol PDListsControllerDelegate

- (UITableViewCell *)cellForListsController:(PDListsController *)controller;

- (void)listsController:(PDListsController *)controller
		  didSelectList:(PDList *)list;

- (void)listsController:(PDListsController *)controller
		  configureCell:(UITableViewCell *)cell
			   withList:(PDList *)list;

@end