#import "DOAppDelegate.h"

#import "../Singletons/PDPersistenceController.h"
#import "../Controllers/DOListsViewController.h"
#import "../Controllers/DOEntriesViewController.h"

@implementation DOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[PDPersistenceController sharedPersistenceController] createFirstLaunchData];
	
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[PDPersistenceController sharedPersistenceController] save];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[window release];
	[super dealloc];
}

@end
