@class DOListsViewController;
@class DOEntriesViewController;

@interface DOAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	
	IBOutlet UISplitViewController *splitViewController;
	IBOutlet DOListsViewController *listsViewController;
	IBOutlet DOEntriesViewController *entriesViewController;
}

@end
