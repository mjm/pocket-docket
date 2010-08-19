#import "PDResource.h"

@interface Entry : PDResource

@property (nonatomic, retain) NSString *entryId;
@property (nonatomic, retain) NSString *listId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSNumber *checked;
@property (nonatomic, retain) NSNumber *position;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

@end
