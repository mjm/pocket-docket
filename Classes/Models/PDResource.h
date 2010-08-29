@interface PDResource : NSObject

@property (nonatomic, retain) NSNumber *moved;
@property (nonatomic, retain) NSNumber *updated;

+ (NSString *)entityName;
- (NSString *)entityName;

+ (NSString *)remoteElement:(NSString *)elementId pathForAction:(NSString *)action;
- (NSString *)remoteElementPathForAction:(NSString *)action;

- (BOOL)moveRemoteWithResponse:(NSError **)aError;
- (BOOL)gotMoveRemoteWithResponse:(NSError **)aError;

- (BOOL)gotUpdateRemoteWithResponse:(NSError **)aError;

@end
