#import "PDLocalChanging.h"

@interface PDPendingChange : NSObject

@property (nonatomic, retain) NSManagedObject <PDLocalChanging> *changed;
@property (nonatomic, retain) NSString *objectID;
@property (nonatomic, retain) NSString *remoteID;
@property (nonatomic, retain) NSString *changeType;

- (id)initWithManagedObject:(NSManagedObject <PDLocalChanging> *)object changeType:(NSString *)changeType;

@end