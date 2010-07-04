#import "PDListsController.h"

#import "../PDPersistenceController.h"


@interface PDListsController ()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end


@implementation PDListsController

- (id)init
{
	if (![super init])
		return nil;
	
	self.selection = nil;
	self.fetchedResultsController = [[PDPersistenceController sharedPersistenceController] listsFetchedResultsController];
	self.fetchedResultsController.delegate = self;
	
	return self;
}

- (void)loadData
{
	NSError *error = nil;
	[self.fetchedResultsController performFetch:&error];
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
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	UITableViewCell *cell = [self.delegate cellForListsController:self];
	[self.delegate listsController:self configureCell:cell withList:list];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toIndexPath:(NSIndexPath *)destinationIndexPath
{
	movingList = YES;
	
	PDList *list = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
	[[PDPersistenceController sharedPersistenceController] moveList:list
															fromRow:sourceIndexPath.row
															  toRow:destinationIndexPath.row];
	
	movingList = NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if ([list isEqual:self.selection])
	{
		NSInteger row = indexPath.row - 1;
		if (row < 0) row = indexPath.row + 1;
		
		if (row < [self tableView:self.tableView numberOfRowsInSection:0])
		{
			NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
			PDList *list = [self.fetchedResultsController objectAtIndexPath:path];
			
			self.selection = list;
		}
		else
		{
			self.selection = nil;
		}
	}
	
	PDPersistenceController *persistenceController = [PDPersistenceController sharedPersistenceController];
	[persistenceController deleteList:list];
	[persistenceController save];
}


#pragma mark -
#pragma mark Table View Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 65.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PDList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.delegate listsController:self didSelectList:list];
}


#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	if (movingList)
		return;
	
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if (movingList)
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
			[self.delegate listsController:self
							 configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
								  withList:anObject];
			break;
			
		case NSFetchedResultsChangeMove:
			if (!movingList)
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
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	self.fetchedResultsController = nil;
	self.selection = nil;
	self.tableView = nil;
	[super dealloc];
}

@end
