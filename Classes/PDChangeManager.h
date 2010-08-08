#import "PDChanging.h"

extern NSString *PDChangeTypeCreate;
extern NSString *PDChangeTypeUpdate;
extern NSString *PDChangeTypeDelete;

@interface PDChangeManager : NSObject

@property (nonatomic, copy) NSString *path;

+ (PDChangeManager *)changeManagerWithContentsOfFile:(NSString *)path;

- (id)initWithContentsOfFile:(NSString *)path;

- (void)addChange:(NSManagedObject <PDChanging> *)changed
	   changeType:(NSString *)changeType;

- (void)commitPendingChanges;
- (void)clearPendingChanges;

- (void)saveChanges;

@end
