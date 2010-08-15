#import "ObjectiveResource.h"
#import "../Changes/PDDeviceResource.h"
#import "../Changes/PDRemoteChanging.h"

@interface Change : PDDeviceResource <NSCoding>

@property (nonatomic, retain) NSString *changeId;
@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSString *model;
@property (nonatomic, retain) NSString *modelId;
@property (nonatomic, retain) NSString *event;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

@property (nonatomic, readonly) Class <PDRemoteChanging> resourceClass;

//+ (NSArray *)findAllRemoteSince:(NSDate *)date response:(NSError **)error;

@end
