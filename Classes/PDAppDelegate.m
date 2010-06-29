#import "PDAppDelegate.h"

#import "PDPersistenceController.h"
#import "Controllers/PDListsViewController.h"
#import "Controllers/PDEntriesViewController.h"

@implementation PDAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[[PDPersistenceController sharedPersistenceController] createFirstLaunchData];
	
	PDListsViewController *listsController = [[PDListsViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:listsController];
	
	PDList *selectedList = [[PDPersistenceController sharedPersistenceController] loadSelectedList];
	if (selectedList) {
		PDEntriesViewController *listController = [[PDEntriesViewController alloc] initWithList:selectedList];
		[navController pushViewController:listController animated:NO];
		[listController release];
	}
	[listsController release];
	
	[self.window addSubview:navController.view];
	[self.window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[PDPersistenceController sharedPersistenceController] save];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.window = nil;
	[super dealloc];
}


@end

