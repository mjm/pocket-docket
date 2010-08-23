#import "_PDList.h"

@interface PDList : _PDList {}

@property (nonatomic, retain) NSArray *completedEntries;
@property (nonatomic, retain) NSArray *allEntries;

- (NSString *)plainTextString;

@end
