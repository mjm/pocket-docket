#import "PDSettingsController.h"

#import "SynthesizeSingleton.h"
#import "PDPersistenceController.h"
#import "Models/PDList.h"
#import "Categories/NSManagedObject+Additions.h"
#import "Categories/NSManagedObjectContext+Additions.h"

@implementation PDSettingsController

NSString * const SelectedListIdKey = @"PDSelectedListId";
NSString * const FirstLaunchKey = @"PDFirstLaunch";
NSString * const LastSyncDateKey = @"PDLastSyncDate";

SYNTHESIZE_SINGLETON_FOR_CLASS(PDSettingsController, SettingsController)

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
												  forKey:FirstLaunchKey]];
}

- (void)saveSelectedList:(PDList *)list
{
	[[NSUserDefaults standardUserDefaults] setObject:[list objectIDString] forKey:SelectedListIdKey];
}

- (PDList *)loadSelectedList
{
	NSString *idString = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedListIdKey];
	if (idString == nil)
		return nil;
	
	NSManagedObjectContext *managedObjectContext = [[PDPersistenceController sharedPersistenceController] managedObjectContext];
	PDList *list = (PDList *) [managedObjectContext objectWithIDString:idString];
	
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

- (NSDate *)lastSyncDate
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:LastSyncDateKey];
}

- (void)setLastSyncDate:(NSDate *)date
{
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:LastSyncDateKey];
}

@end
