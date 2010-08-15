@protocol PDRemoteChanging <NSObject>

+ (NSString *)entityName;
- (void)copyPropertiesTo:(NSManagedObject *)object;

@end
