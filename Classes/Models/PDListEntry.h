@class PDList;

@interface PDListEntry : NSManagedObject {

}

@property (nonatomic, retain) NSNumber *checked;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) PDList *list;

@end
