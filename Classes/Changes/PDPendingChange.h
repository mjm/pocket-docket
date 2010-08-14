#import "PDChanging.h"

@interface PDPendingChange : NSObject

@property (nonatomic, retain) NSManagedObject <PDChanging> *changed;
@property (nonatomic, retain) NSString *objectID;
@property (nonatomic, retain) NSString *remoteID;
@property (nonatomic, retain) NSString *changeType;

- (id)initWithManagedObject:(NSManagedObject <PDChanging> *)object changeType:(NSString *)changeType;

@end