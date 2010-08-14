@interface PDKeychainManager : NSObject

+ (PDKeychainManager *)sharedKeychainManager;

- (NSString *)retrievePasswordForAccount:(NSString *)account service:(NSString *)service;
- (void)setPassword:(NSString *)password forAccount:(NSString *)account service:(NSString *)service;
- (void)erasePasswordForAccount:(NSString *)account service:(NSString *)service;

@end
