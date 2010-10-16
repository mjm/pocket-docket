#import "PDResource.h"

@interface List : PDResource

@property (nonatomic, retain) NSString *listId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *position;
@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

+ (NSString *)entityName;
+ (NSInvocation *)findAllRemoteInvocation;
+ (BOOL)sortRemote:(NSArray *)ids withResponse:(NSError **)aError;

@end
