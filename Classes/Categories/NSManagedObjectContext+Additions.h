@interface NSManagedObjectContext (Additions)

- (NSManagedObject *)objectWithIDString:(NSString *)idString;
- (NSManagedObject *)existingObjectWithIDString:(NSString *)idString error:(NSError **)error;
- (NSManagedObjectModel *)managedObjectModel;

@end
