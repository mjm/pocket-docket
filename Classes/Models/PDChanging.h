@protocol PDChanging <NSObject>

@property (nonatomic, retain) NSString *remoteIdentifier;

- (id)toResource;

@end
