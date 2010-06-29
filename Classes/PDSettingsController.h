@class PDList;

@interface PDSettingsController : NSObject {}

+ (PDSettingsController *)sharedSettingsController;

- (void)saveSelectedList:(PDList *)list;
- (PDList *)loadSelectedList;

@property (nonatomic, getter=isFirstLaunch) BOOL firstLaunch;

@end
