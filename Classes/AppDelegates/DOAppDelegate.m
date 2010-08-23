#import "DOAppDelegate.h"

#import "../Singletons/PDPersistenceController.h"
#import "../Controllers/DOListsViewController.h"
#import "../Controllers/DOEntriesViewController.h"
#import "ObjectiveResourceConfig.h"

@implementation DOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[ObjectiveResourceConfig setSite:@"http://docketanywhere.com/"];
	[ObjectiveResourceConfig setResponseType:JSONResponse];
	
	[[PDPersistenceController sharedPersistenceController] createFirstLaunchData];
	
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];
	
	[[PDPersistenceController sharedPersistenceController] save];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[PDPersistenceController sharedPersistenceController] save];
}

#pragma mark -
#pragma mark Memory management
                                                  
@end
