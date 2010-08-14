@interface PDChange : NSObject

@property (nonatomic, retain) NSString *changeType;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, readonly, getter=isLocal) BOOL local;
@property (nonatomic, readonly) NSString *changeId;

- (id)initWithType:(NSString *)changeType date:(NSDate *)date;

- (PDChange *)changeByMergingWithChange:(PDChange *)change;
- (void)executeOnManagedObjectContext:(NSManagedObjectContext *)context;

@end
