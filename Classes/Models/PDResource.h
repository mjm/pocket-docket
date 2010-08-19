@interface NSObject (DeviceMethods)

+ (NSString *)deviceId;
+ (void)setDeviceId:(NSString *)deviceId;

@end


@interface PDResource : NSObject

@property (nonatomic, retain) NSNumber *moved;

+ (NSString *)entityName;
- (NSString *)entityName;

+ (NSString *)remoteElement:(NSString *)elementId pathForAction:(NSString *)action;
- (NSString *)remoteElementPathForAction:(NSString *)action;

- (BOOL)moveRemoteWithResponse:(NSError **)aError;
- (BOOL)gotMoveRemoteWithResponse:(NSError **)aError;

@end
