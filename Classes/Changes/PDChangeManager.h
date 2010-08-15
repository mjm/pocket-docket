#import "PDLocalChanging.h"

@class PDCredentials;

extern NSString *PDChangeTypeCreate;
extern NSString *PDChangeTypeUpdate;
extern NSString *PDChangeTypeDelete;


@protocol PDChangeManagerDelegate;


@interface PDChangeManager : NSObject
{
	BOOL attemptRemote;
}

@property (nonatomic, assign) id <PDChangeManagerDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) NSString *path;

+ (PDChangeManager *)changeManagerWithContentsOfFile:(NSString *)path;

- (id)initWithContentsOfFile:(NSString *)path;

- (void)addChange:(NSManagedObject <PDLocalChanging> *)changed
	   changeType:(NSString *)changeType;

- (void)commitPendingChanges;
- (void)clearPendingChanges;

- (void)refreshAndPublishChanges;
- (void)saveChanges;

@end


@protocol PDChangeManagerDelegate <NSObject>

- (PDCredentials *)credentialsForChangeManager:(PDChangeManager *)changeManager;

@end