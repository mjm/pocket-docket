@class DOListsViewController;
@class DOEntriesViewController;

@interface DOAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	
	IBOutlet UISplitViewController *splitViewController;
	IBOutlet DOListsViewController *listsViewController;
	IBOutlet DOEntriesViewController *entriesViewController;
	
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

@end
