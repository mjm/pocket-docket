#import "Change.h"
#import "Connection.h"
#import "Response.h"

static NSString * const SinceDateKey = @"since";

@implementation Change

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	self.changeId = [coder decodeObjectForKey:@"PDChangeId"];
	self.userId = [coder decodeObjectForKey:@"PDUserId"];
	self.model = [coder decodeObjectForKey:@"PDModel"];
	self.modelId = [coder decodeObjectForKey:@"PDModelId"];
	self.event = [coder decodeObjectForKey:@"PDEvent"];
	self.createdAt = [coder decodeObjectForKey:@"PDCreatedAt"];
	self.updatedAt = [coder decodeObjectForKey:@"PDUpdatedAt"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.changeId forKey:@"PDChangeId"];
	[coder encodeObject:self.userId forKey:@"PDUserId"];
	[coder encodeObject:self.model forKey:@"PDModel"];
	[coder encodeObject:self.modelId forKey:@"PDModelId"];
	[coder encodeObject:self.event forKey:@"PDEvent"];
	[coder encodeObject:self.createdAt forKey:@"PDCreatedAt"];
	[coder encodeObject:self.updatedAt forKey:@"PDUpdatedAt"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<Change:%@ model=%@:%@, event=%@, userId=%@, createdAt=%@>", self.changeId, self.model, self.modelId, self.event, self.userId, self.createdAt];
}

+ (NSArray *)findAllRemoteSince:(NSDate *)date response:(NSError **)error
{
	NSString *path = [[self getRemoteCollectionPath] stringByAppendingString:@"?since=:since"];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyyMMddHHmmss";
	NSString *dateStr = [formatter stringFromDate:[date dateByAddingTimeInterval:-[[NSTimeZone defaultTimeZone] secondsFromGMTForDate:date]]];
	[formatter release];
	
	NSDictionary *params = [NSDictionary dictionaryWithObject:dateStr forKey:SinceDateKey];
	path = [self populateRemotePath:path withParameters:params];
	
	Response *res = [Connection get:path withUser:[[self class] getRemoteUser] andPassword:[[self class] getRemotePassword]];
	if([res isError] && error)
	{
		*error = res.error;
		return nil;
	}
	else
	{
		return [self performSelector:[self getRemoteParseDataMethod] withObject:res.body];
	}
}

- (Class <PDRemoteChanging>)resourceClass
{
	return NSClassFromString(self.model);
}

@end
