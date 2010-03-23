@interface PDList : NSManagedObject {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) NSSet *entries;

@end
