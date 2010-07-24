#import "PDSettingsController.h"

#import "SynthesizeSingleton.h"
#import "PDPersistenceController.h"
#import "Models/PDList.h"

@implementation PDSettingsController

NSString * const SelectedListIdKey = @"PDSelectedListId";
NSString * const FirstLaunchKey = @"PDFirstLaunch";

SYNTHESIZE_SINGLETON_FOR_CLASS(PDSettingsController, SettingsController)

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
												  forKey:FirstLaunchKey]];
}

- (void)saveSelectedList:(PDList *)list
{
	NSString *idString = [[[list objectID] URIRepresentation] absoluteString];
	[[NSUserDefaults standardUserDefaults] setObject:idString forKey:SelectedListIdKey];
}

- (PDList *)loadSelectedList
{
	NSString *idString = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedListIdKey];
	if (idString == nil)
		return nil;
	
	NSManagedObjectContext *managedObjectContext = [[PDPersistenceController sharedPersistenceController] managedObjectContext];
	NSManagedObjectID *objectId = [[managedObjectContext persistentStoreCoordinator]
								   managedObjectIDForURIRepresentation:[NSURL URLWithString:idString]];
	PDList *list = (PDList *) [managedObjectContext objectWithID:objectId];
	
	@try {
		NSString *title = [list.title copy]; // fire the fault
        [title release];
	}
	@catch (NSException * e) {
		return nil;
	}
	return list;
}

- (BOOL)isFirstLaunch
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchKey];
}

- (void)setFirstLaunch:(BOOL)firstLaunch
{
	[[NSUserDefaults standardUserDefaults] setBool:firstLaunch forKey:FirstLaunchKey];
}

@end
