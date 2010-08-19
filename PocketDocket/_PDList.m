// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PDList.m instead.

#import "_PDList.h"

@implementation PDListID
@end

@implementation _PDList

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"List";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"List" inManagedObjectContext:moc_];
}

- (PDListID*)objectID {
	return (PDListID*)[super objectID];
}




@dynamic createdAt;






@dynamic title;






@dynamic order;



- (int)orderValue {
	NSNumber *result = [self order];
	return [result intValue];
}

- (void)setOrderValue:(int)value_ {
	[self setOrder:[NSNumber numberWithInt:value_]];
}

- (int)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result intValue];
}

- (void)setPrimitiveOrderValue:(int)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithInt:value_]];
}





@dynamic movedSinceSync;



- (BOOL)movedSinceSyncValue {
	NSNumber *result = [self movedSinceSync];
	return [result boolValue];
}

- (void)setMovedSinceSyncValue:(BOOL)value_ {
	[self setMovedSinceSync:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMovedSinceSyncValue {
	NSNumber *result = [self primitiveMovedSinceSync];
	return [result boolValue];
}

- (void)setPrimitiveMovedSinceSyncValue:(BOOL)value_ {
	[self setPrimitiveMovedSinceSync:[NSNumber numberWithBool:value_]];
}





@dynamic remoteIdentifier;






@dynamic updatedAt;






@dynamic entries;

	
- (NSMutableSet*)entriesSet {
	[self willAccessValueForKey:@"entries"];
	NSMutableSet *result = [self mutableSetValueForKey:@"entries"];
	[self didAccessValueForKey:@"entries"];
	return result;
}
	




+ (NSArray*)fetchListsAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ {
	NSError *error = nil;
	NSArray *result = [self fetchListsAbove:moc_ position:position_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchListsAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														position_, @"position",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"listsAbove"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"listsAbove\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchListsBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ {
	NSError *error = nil;
	NSArray *result = [self fetchListsBetween:moc_ minRow:minRow_ maxRow:maxRow_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchListsBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														minRow_, @"minRow",
														
														maxRow_, @"maxRow",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"listsBetween"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"listsBetween\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchListWithRemoteId:(NSManagedObjectContext*)moc_ remoteId:(NSString*)remoteId_ {
	NSError *error = nil;
	NSArray *result = [self fetchListWithRemoteId:moc_ remoteId:remoteId_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchListWithRemoteId:(NSManagedObjectContext*)moc_ remoteId:(NSString*)remoteId_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														remoteId_, @"remoteId",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"listWithRemoteId"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"listWithRemoteId\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchAllLists:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *result = [self fetchAllLists:moc_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchAllLists:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = nil;
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"allLists"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"allLists\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}


@end
