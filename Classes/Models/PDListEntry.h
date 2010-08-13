#import "PDChanging.h"

@class PDList;

@interface PDListEntry : NSManagedObject <PDChanging>

@property (nonatomic, retain) NSNumber *checked;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *remoteIdentifier;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) PDList *list;

- (NSString *)plainTextString;

@end
