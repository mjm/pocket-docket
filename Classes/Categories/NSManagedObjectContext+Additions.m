#import "NSManagedObjectContext+Additions.h"


@implementation NSManagedObjectContext (Additions)

- (NSManagedObject *)objectWithIDString:(NSString *)idString
{
	return [self objectWithID:[[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:idString]]];
}

- (NSManagedObjectModel *)managedObjectModel
{
	return [[self persistentStoreCoordinator] managedObjectModel];
}

@end
