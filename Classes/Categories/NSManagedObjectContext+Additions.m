#import "NSManagedObjectContext+Additions.h"


@implementation NSManagedObjectContext (Additions)

- (NSManagedObject *)objectWithIDString:(NSString *)idString
{
	return [self objectWithID:[[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:idString]]];
}

@end
