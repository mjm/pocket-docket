#import "../Changes/PDRemoteChanging.h"
#import "../Changes/PDDeviceResource.h"

@interface List : PDDeviceResource <PDRemoteChanging>

@property (nonatomic, retain) NSString *listId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *position;
@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

+ (NSInvocation *)findAllRemoteInvocation;

@end
