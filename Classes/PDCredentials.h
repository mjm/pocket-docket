@interface PDCredentials : NSObject

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *deviceId;

+ (PDCredentials *)credentialsWithUsername:(NSString *)username
								  password:(NSString *)password
								  deviceId:(NSString *)deviceId;

- (id)initWithUsername:(NSString *)username
			  password:(NSString *)password
			  deviceId:(NSString *)deviceId;

@end
