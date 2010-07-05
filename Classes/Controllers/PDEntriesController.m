#import "PDEntriesController.h"

#import "../PDPersistenceController.h"
#import "../Models/PDList.h"
#import "../Models/PDListEntry.h"
#import "../Views/PDEntryTableCell.h"


@interface PDEntriesController ()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end


@implementation PDEntriesController

- (id)init
{
	if (![super init])
		return nil;
	
	self.list = nil;
	
	return self;
}

- (void)loadData
{
	if (self.list)
	{
		self.fetchedResultsController = [[PDPersistenceController sharedPersistenceController] entriesFetchedResultsControllerForList:self.list];
		self.fetchedResultsController.delegate = self;
		
		NSError *error = nil;
		[self.fetchedResultsController performFetch:&error];
	}
	else
	{
		self.fetchedResultsController = nil;
	}
}

- (void)checkEntryAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath != nil)
	{
		PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
		entry.checked = [NSNumber numberWithBool:![entry.checked boolValue]];
		
		PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
		[persistenceController save];
		[persistenceController.managedObjectContext refreshObject:self.list mergeChanges:YES];
	}
}

- (PDListEntry *)entryAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)bindToListsController:(PDListsController *)controller
{
	self.listsController = controller;
	[controller addObserver:self
				 forKeyPath:@"selection"
					options:NSKeyValueObservingOptionNew
					context:NULL];
}


#pragma mark -
#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if ([keyPath isEqualToString:@"selection"])
	{
		id list = [change objectForKey:NSKeyValueChangeNewKey];
		if (list != [NSNull null])
		{
			self.list = list;
			self.fetchedResultsController = [[PDPersistenceController sharedPersistenceController] entriesFetchedResultsControllerForList:list];
			self.fetchedResultsController.delegate = self;
			
			NSError *error = nil;
			[self.fetchedResultsController performFetch:&error];
			
			[self.tableView reloadData];
		}
	}
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	UITableViewCell *cell = [self.delegate cellForEntriesController:self];
	[self.delegate entriesController:self configureCell:cell withEntry:entry];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController deleteEntry:entry];
	[persistenceController save];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toIndexPath:(NSIndexPath *)destinationIndexPath
{
	movingEntries = YES;
	
	PDListEntry *entry = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
	[[PDPersistenceController sharedPersistenceController] moveEntry:entry
															 fromRow:sourceIndexPath.row
															   toRow:destinationIndexPath.row];
	
	movingEntries = NO;
}


#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (movingEntries)
		return;
	
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (movingEntries)
		return;
	
	[self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type)
	{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self.delegate entriesController:self
							   configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
								   withEntry:anObject];
			break;
			
		case NSFetchedResultsChangeMove:
			if (!movingEntries)
			{
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
									  withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
									  withRowAnimation:UITableViewRowAnimationFade];
			}
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
	return;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[self.listsController removeObserver:self forKeyPath:@"selection"];
	
	self.fetchedResultsController = nil;
	self.list = nil;
	self.tableView = nil;
	self.listsController = nil;
	[super dealloc];
}

@end
