#import "_PDListEntry.h"

@interface PDListEntry : _PDListEntry {}

- (NSString *)plainTextString;

// This shouldn't be necessary but MOGenerator seems to be screwing up

@property (nonatomic, retain) NSNumber *updatedSinceSync;

@property BOOL updatedSinceSyncValue;
- (BOOL)updatedSinceSyncValue;
- (void)setUpdatedSinceSyncValue:(BOOL)value_;

@end
