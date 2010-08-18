#import "PDSettingsController.h"

#import "SynthesizeSingleton.h"
#import "PDPersistenceController.h"
#import "PDKeychainManager.h"
#import "PDList.h"
#import "../Categories/NSManagedObject+Additions.h"
#import "../Categories/NSManagedObjectContext+Additions.h"

@implementation PDSettingsController

static NSString * const DocketAnywhereService = @"com.docketanywhere.DocketAnywhere";

static NSString * const SelectedListIdKey = @"PDSelectedListId";
static NSString * const FirstLaunchKey = @"PDFirstLaunch";
static NSString * const LastSyncDateKey = @"PDLastSyncDate";
static NSString * const DocketAnywhereUsernameKey = @"PDDocketAnywhereUsername";
static NSString * const DocketAnywhereDeviceIdKey = @"PDDocketAnywhereDeviceId";

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

- (NSString *)docketAnywhereUsername
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:DocketAnywhereUsernameKey];
}

- (void)setDocketAnywhereUsername:(NSString *)username
{
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:DocketAnywhereUsernameKey];
}

- (NSString *)docketAnywherePassword
{
	NSString *username = self.docketAnywhereUsername;
	if (!username)
	{
		return nil;
	}
	return [[PDKeychainManager sharedKeychainManager] retrievePasswordForAccount:username service:DocketAnywhereService];
}

- (void)setDocketAnywherePassword:(NSString *)password
{
	NSString *username = self.docketAnywhereUsername;
	if (!username)
	{
		return;
	}
	[[PDKeychainManager sharedKeychainManager] setPassword:password forAccount:username service:DocketAnywhereService];
}

- (NSString *)docketAnywhereDeviceId
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:DocketAnywhereDeviceIdKey];
	//return @"1";
}

- (void)setDocketAnywhereDeviceId:(NSString *)deviceId
{
	[[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:DocketAnywhereDeviceIdKey];
}

@end
