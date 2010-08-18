// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PDListEntry.h instead.

#import <CoreData/CoreData.h>


@class PDList;










@interface PDListEntryID : NSManagedObjectID {}
@end

@interface _PDListEntry : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PDListEntryID*)objectID;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *movedSinceSync;

@property BOOL movedSinceSyncValue;
- (BOOL)movedSinceSyncValue;
- (void)setMovedSinceSyncValue:(BOOL)value_;

//- (BOOL)validateMovedSinceSync:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *remoteIdentifier;

//- (BOOL)validateRemoteIdentifier:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property int orderValue;
- (int)orderValue;
- (void)setOrderValue:(int)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *comment;

//- (BOOL)validateComment:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *checked;

@property BOOL checkedValue;
- (BOOL)checkedValue;
- (void)setCheckedValue:(BOOL)value_;

//- (BOOL)validateChecked:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) PDList* list;
//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;




+ (NSArray*)fetchEntriesAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ list:(PDList*)list_ ;
+ (NSArray*)fetchEntriesAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ list:(PDList*)list_ error:(NSError**)error_;



+ (NSArray*)fetchEntriesForList:(NSManagedObjectContext*)moc_ list:(PDList*)list_ ;
+ (NSArray*)fetchEntriesForList:(NSManagedObjectContext*)moc_ list:(PDList*)list_ error:(NSError**)error_;



+ (NSArray*)fetchEntriesBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ list:(PDList*)list_ ;
+ (NSArray*)fetchEntriesBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ list:(PDList*)list_ error:(NSError**)error_;


@end

@interface _PDListEntry (CoreDataGeneratedAccessors)

@end

@interface _PDListEntry (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;


- (NSNumber*)primitiveMovedSinceSync;
- (void)setPrimitiveMovedSinceSync:(NSNumber*)value;

- (BOOL)primitiveMovedSinceSyncValue;
- (void)setPrimitiveMovedSinceSyncValue:(BOOL)value_;


- (NSString*)primitiveRemoteIdentifier;
- (void)setPrimitiveRemoteIdentifier:(NSString*)value;


- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int)value_;


- (NSString*)primitiveComment;
- (void)setPrimitiveComment:(NSString*)value;


- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;


- (NSNumber*)primitiveChecked;
- (void)setPrimitiveChecked:(NSNumber*)value;

- (BOOL)primitiveCheckedValue;
- (void)setPrimitiveCheckedValue:(BOOL)value_;


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (PDList*)primitiveList;
- (void)setPrimitiveList:(PDList*)value;


@end
