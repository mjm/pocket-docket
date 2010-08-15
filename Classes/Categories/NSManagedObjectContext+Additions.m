#import "NSManagedObjectContext+Additions.h"


@implementation NSManagedObjectContext (Additions)

- (NSManagedObjectID *)objectIDFromString:(NSString *)idString
{
	return [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:idString]];
}

- (NSManagedObject *)objectWithIDString:(NSString *)idString
{
	return [self objectWithID:[self objectIDFromString:idString]];
}

- (NSManagedObject *)existingObjectWithIDString:(NSString *)idString error:(NSError **)error
{
	return [self existingObjectWithID:[self objectIDFromString:idString] error:error];
}

- (NSManagedObjectModel *)managedObjectModel
{
	return [[self persistentStoreCoordinator] managedObjectModel];
}

@end
