#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (Additions)

- (NSString *)objectIDString
{
	return [[[self objectID] URIRepresentation] absoluteString];
}

@end
