#import "_PDList.h"

@interface PDList : _PDList {}

@property (nonatomic, retain) NSArray *completedEntries;

- (NSString *)plainTextString;

@end
