#import "_PDList.h"

@interface PDList : _PDList {}

@property (nonatomic, retain) NSArray *completedEntries;
@property (nonatomic, retain) NSArray *allEntries;

- (NSString *)plainTextString;


// This shouldn't be necessary but MOGenerator seems to be screwing up

@property (nonatomic, retain) NSNumber *updatedSinceSync;

@property BOOL updatedSinceSyncValue;
- (BOOL)updatedSinceSyncValue;
- (void)setUpdatedSinceSyncValue:(BOOL)value_;

- (NSNumber *)primitiveUpdatedSinceSync;
- (void)setPrimitiveUpdatedSinceSync:(NSNumber *)value_;

@end
