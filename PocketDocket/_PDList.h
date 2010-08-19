// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PDList.h instead.

#import <CoreData/CoreData.h>


@class PDListEntry;








@interface PDListID : NSManagedObjectID {}
@end

@interface _PDList : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PDListID*)objectID;



@property (nonatomic, retain) NSDate *createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property int orderValue;
- (int)orderValue;
- (void)setOrderValue:(int)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *movedSinceSync;

@property BOOL movedSinceSyncValue;
- (BOOL)movedSinceSyncValue;
- (void)setMovedSinceSyncValue:(BOOL)value_;

//- (BOOL)validateMovedSinceSync:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *remoteIdentifier;

//- (BOOL)validateRemoteIdentifier:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* entries;
- (NSMutableSet*)entriesSet;




+ (NSArray*)fetchListsAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ ;
+ (NSArray*)fetchListsAbove:(NSManagedObjectContext*)moc_ position:(NSNumber*)position_ error:(NSError**)error_;



+ (NSArray*)fetchListsBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ ;
+ (NSArray*)fetchListsBetween:(NSManagedObjectContext*)moc_ minRow:(NSNumber*)minRow_ maxRow:(NSNumber*)maxRow_ error:(NSError**)error_;



+ (NSArray*)fetchListWithRemoteId:(NSManagedObjectContext*)moc_ remoteId:(NSString*)remoteId_ ;
+ (NSArray*)fetchListWithRemoteId:(NSManagedObjectContext*)moc_ remoteId:(NSString*)remoteId_ error:(NSError**)error_;



+ (NSArray*)fetchAllLists:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchAllLists:(NSManagedObjectContext*)moc_ error:(NSError**)error_;


@end

@interface _PDList (CoreDataGeneratedAccessors)

- (void)addEntries:(NSSet*)value_;
- (void)removeEntries:(NSSet*)value_;
- (void)addEntriesObject:(PDListEntry*)value_;
- (void)removeEntriesObject:(PDListEntry*)value_;

@end

@interface _PDList (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int)value_;


- (NSNumber*)primitiveMovedSinceSync;
- (void)setPrimitiveMovedSinceSync:(NSNumber*)value;

- (BOOL)primitiveMovedSinceSyncValue;
- (void)setPrimitiveMovedSinceSyncValue:(BOOL)value_;


- (NSString*)primitiveRemoteIdentifier;
- (void)setPrimitiveRemoteIdentifier:(NSString*)value;


- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSMutableSet*)primitiveEntries;
- (void)setPrimitiveEntries:(NSMutableSet*)value;


@end
