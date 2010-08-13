#import "PDAppDelegate.h"

#import "ObjectiveResourceConfig.h"
#import "PDPersistenceController.h"
#import "PDSettingsController.h"
#import "PDKeychainManager.h"
#import "Controllers/PDListsViewController.h"
#import "Controllers/PDEntriesViewController.h"

@implementation PDAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[ObjectiveResourceConfig setSite:@"http://10.0.1.13:3000/"];
	[ObjectiveResourceConfig setResponseType:JSONResponse];
	
	[[PDPersistenceController sharedPersistenceController] createFirstLaunchData];
	
	PDListsViewController *listsController = [[PDListsViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:listsController];
	
	PDList *selectedList = [[PDSettingsController sharedSettingsController] loadSelectedList];
	if (selectedList)
	{
		PDEntriesViewController *listController = [[PDEntriesViewController alloc] initWithList:selectedList];
		[navController pushViewController:listController animated:NO];
		[listController release];
	}
	[listsController release];
	
	[self.window addSubview:navController.view];
	[self.window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[PDPersistenceController sharedPersistenceController] save];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.window = nil;
	[super dealloc];
}


@end

