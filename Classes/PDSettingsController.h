@class PDList;

@interface PDSettingsController : NSObject

+ (PDSettingsController *)sharedSettingsController;

- (void)saveSelectedList:(PDList *)list;
- (PDList *)loadSelectedList;

@property (nonatomic, getter=isFirstLaunch) BOOL firstLaunch;
@property (nonatomic, retain) NSDate *lastSyncDate;
@property (nonatomic, retain) NSString *docketAnywhereUsername;
@property (nonatomic, retain) NSString *docketAnywherePassword;

@end
