#import "PDChanging.h"

@interface PDList : NSManagedObject <PDChanging>

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) NSString *remoteIdentifier;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) NSArray *completedEntries;

- (NSString *)plainTextString;

@end
