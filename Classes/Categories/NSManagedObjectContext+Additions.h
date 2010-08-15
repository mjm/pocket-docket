@interface NSManagedObjectContext (Additions)

- (NSManagedObject *)objectWithIDString:(NSString *)idString;
- (NSManagedObjectModel *)managedObjectModel;

@end
