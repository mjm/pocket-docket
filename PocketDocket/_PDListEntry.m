// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PDListEntry.m instead.

#import "_PDListEntry.h"

@implementation PDListEntryID
@end

@implementation _PDListEntry

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ListEntry" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ListEntry";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ListEntry" inManagedObjectContext:moc_];
}

- (PDListEntryID*)objectID {
	return (PDListEntryID*)[super objectID];
}




@dynamic text;






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





@dynamic deletedAt;






@dynamic remoteIdentifier;






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





@dynamic updatedAt;






@dynamic comment;






@dynamic checked;



- (BOOL)checkedValue {
	NSNumber *result = [self checked];
	return [result boolValue];
}

- (void)setCheckedValue:(BOOL)value_ {
	[self setChecked:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCheckedValue {
	NSNumber *result = [self primitiveChecked];
	return [result boolValue];
}

- (void)setPrimitiveCheckedValue:(BOOL)value_ {
	[self setPrimitiveChecked:[NSNumber numberWithBool:value_]];
}





@dynamic createdAt;






@dynamic list;

	




+ (NSArray*)fetchEntriesForList:(NSManagedObjectContext*)moc_ list:(PDList*)list_ {
	NSError *error = nil;
	NSArray *result = [self fetchEntriesForList:moc_ list:list_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchEntriesForList:(NSManagedObjectContext*)moc_ list:(PDList*)list_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														list_, @"list",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"entriesForList"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"entriesForList\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchEntryWithRemoteId:(NSManagedObjectContext*)moc_ remoteId:(NSString*)remoteId_ {
	NSError *error = nil;
	NSArray *result = [self fetchEntryWithRemoteId:moc_ remoteId:remoteId_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchEntryWithRemoteId:(NSManagedObjectContext*)moc_ remoteId:(NSString*)remoteId_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														remoteId_, @"remoteId",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"entryWithRemoteId"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"entryWithRemoteId\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchEntriesBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ list:(PDList*)list_ {
	NSError *error = nil;
	NSArray *result = [self fetchEntriesBetween:moc_ minRow:minRow_ maxRow:maxRow_ list:list_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchEntriesBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ list:(PDList*)list_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														minRow_, @"minRow",
														
														maxRow_, @"maxRow",
														
														list_, @"list",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"entriesBetween"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"entriesBetween\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchEntriesAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ list:(PDList*)list_ {
	NSError *error = nil;
	NSArray *result = [self fetchEntriesAbove:moc_ position:position_ list:list_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchEntriesAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ list:(PDList*)list_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObjectsAndKeys:
														
														position_, @"position",
														
														list_, @"list",
														
														nil];
										
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"entriesAbove"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"entriesAbove\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}


@end
