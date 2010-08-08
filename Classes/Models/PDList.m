#import "PDList.h"

#import "PDListEntry.h"
#import "List.h"

@implementation PDList

@dynamic title, order, remoteIdentifier, createdAt, updatedAt, entries, completedEntries;

- (id)toResource
{
	List *list = [[List alloc] init];
	list.title = self.title;
	list.position = self.order;
	list.listId = self.remoteIdentifier;
	return [list autorelease];
}

- (NSString *)plainTextString {
	NSManagedObjectModel *model = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
	NSDictionary *vars = [NSDictionary dictionaryWithObject:self forKey:@"LIST"];
	NSFetchRequest *request = [model fetchRequestFromTemplateWithName:@"entriesForList"
												substitutionVariables:vars];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order"
																   ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *entries = [self.managedObjectContext executeFetchRequest:request
																error:&error];
	if (entries) {
		NSMutableString *buffer = [NSMutableString string];
		for (PDListEntry *entry in entries) {
			[buffer appendString:[entry plainTextString]];
			[buffer appendString:@"\n"];
		}
		return buffer;
	} else {
		NSLog(@"Error generating plain text string for list: %@, %@", error, [error description]);
		return nil;
	}
}

@end
