#import "PDRemoteChange.h"

#import "Change.h"


@interface PDRemoteChange ()

@property (nonatomic, retain) Change *change;

@end


@implementation PDRemoteChange

- (id)initWithChange:(Change *)remoteChange
{
	if (![super initWithType:remoteChange.event date:remoteChange.createdAt])
		return nil;
	
	self.change = remoteChange;
	return self;
}

- (BOOL)isLocal
{
	return NO;
}

- (NSString *)changeId
{
	return [NSString stringWithFormat:@"%@:%@", self.change.model, self.change.modelId];
}


#pragma mark -
#pragma mark Executing a Change

- (void)executeOnManagedObjectContext:(NSManagedObjectContext *)context
{
	
}

@end
