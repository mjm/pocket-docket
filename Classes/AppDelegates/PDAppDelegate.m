#import "PDAppDelegate.h"

#import "ObjectiveResourceConfig.h"
#import "../Singletons/PDPersistenceController.h"
#import "../Singletons/PDSettingsController.h"
#import "../Singletons/PDKeychainManager.h"
#import "../Controllers/PDListsViewController.h"
#import "../Controllers/PDEntriesViewController.h"

#if !defined(CONFIGURATION_Release)
#import "BWHockeyController.h"
#endif

@implementation PDAppDelegate

- (void)eraseCredentials
{
	NSString *username = [[PDSettingsController sharedSettingsController] docketAnywhereUsername];
	[[PDKeychainManager sharedKeychainManager] erasePasswordForAccount:username service:@"com.docketanywhere.DocketAnywhere"];
	[PDSettingsController sharedSettingsController].docketAnywhereUsername = nil;
}


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[ObjectiveResourceConfig setSite:@"http://docketanywhere.com/"];
	[ObjectiveResourceConfig setResponseType:JSONResponse];
	
#if !defined(CONFIGURATION_Release)
	[[BWHockeyController sharedHockeyController] setBetaURL:@"http://beta.docketanywhere.com/"];
#endif
	
	[[PDPersistenceController sharedPersistenceController] createFirstLaunchData];
	
	//[self eraseCredentials];
	
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
	
	[[PDPersistenceController sharedPersistenceController] save];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[PDPersistenceController sharedPersistenceController] save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[[PDPersistenceController sharedPersistenceController] save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.window = nil;
	[super dealloc];
}


@end

