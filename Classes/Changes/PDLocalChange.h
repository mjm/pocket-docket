#import "PDChange.h"

@class PDPendingChange;

@interface PDLocalChange : PDChange

- (id)initWithPendingChange:(PDPendingChange *)pendingChange date:(NSDate *)date;

- (BOOL)execute;

@end
