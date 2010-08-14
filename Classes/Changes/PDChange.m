#import "PDChange.h"

#import "PDChangeManager.h"

@implementation PDChange

- (id)initWithType:(NSString *)changeType date:(NSDate *)date
{
	if (![super init])
		return nil;
	
	self.changeType = changeType;
	self.date = date;
	return self;
}

- (PDChange *)changeByMergingWithChange:(PDChange *)change
{
	if ([self.changeType isEqualToString:PDChangeTypeCreate])
	{
		NSAssert(self.local == change.local,
				 @"A creation change should not have subsequent changes from the other side (remote or local)");
		NSAssert(![change.changeType isEqualToString:PDChangeTypeCreate],
				 @"There should not be two creation changes for the same ID.");
		
		if ([change.changeType isEqualToString:PDChangeTypeUpdate])
		{
			// The create will use the most recent data, so an update is not needed.
			return self;
		}
		else // PDChangeTypeDelete
		{
			// A create followed by a delete may as well have never happened, so it won't.
			return nil;
		}
	}
	else if ([self.changeType isEqualToString:PDChangeTypeUpdate])
	{
		NSAssert(![change.changeType isEqualToString:PDChangeTypeCreate],
				 @"An update change should not be followed by a creation change.");
		
		// In the case of an update, always keep the later change.
		// This may turn out to be a delete, which is OK.
		return change;
	}
	else // PDChangeTypeDelete
	{
		NSAssert(self.local != change.local,
				 @"A deletion change should not have subsequent changes from the same side (remote or local)");
		NSAssert(![change.changeType isEqualToString:PDChangeTypeCreate],
				 @"There should not be two creation changes for the same ID.");
		
		if ([change.changeType isEqualToString:PDChangeTypeUpdate])
		{
			// The delete takes priority, since there is no simple way to pretend it never happened.
			return self;
		}
		else // PDChangeTypeDelete
		{
			// Both sides deleted, so both sides are already up-to-date. No change necessary.
			return nil;
		}
	}
}

- (void)executeOnManagedObjectContext:(NSManagedObjectContext *)context
{
	[self doesNotRecognizeSelector:_cmd];
}

- (void)dealloc
{
	self.changeType = nil;
	self.date = nil;
	[super dealloc];
}

@end
