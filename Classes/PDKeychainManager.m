#import "PDKeychainManager.h"

#import <Security/Security.h>
#import "SynthesizeSingleton.h"

@implementation PDKeychainManager

SYNTHESIZE_SINGLETON_FOR_CLASS(PDKeychainManager, KeychainManager)

- (NSString *)retrievePasswordForAccount:(NSString *)account service:(NSString *)service
{
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:account forKey:(id)kSecAttrAccount];
	[query setObject:service forKey:(id)kSecAttrService];
	[query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	NSData *results = nil;
	OSStatus error = SecItemCopyMatching((CFDictionaryRef) query, (CFTypeRef *) &results);
	
	if (errSecSuccess == error)
	{
		NSString *password = [[[NSString alloc] initWithData:(NSData *)results encoding:NSUTF8StringEncoding] autorelease];
		[results release];
		return password;
	}
	else if (errSecItemNotFound == error)
	{
		//NSLog(@"Password for account %@ and service %@ not found.", account, service);
		return nil;
	}
	
	NSLog(@"Error retrieving password: %d", (int) error);
	return nil;
}

- (void)setPassword:(NSString *)password forAccount:(NSString *)account service:(NSString *)service
{
	NSString *oldPassword = [self retrievePasswordForAccount:account service:service];
	
	OSStatus error;
	if (oldPassword)
	{
		if ([oldPassword isEqualToString:password])
		{
			// No need to do anything, the passwords are the same.
			return;
		}
		
		NSMutableDictionary *query = [NSMutableDictionary dictionary];
		[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
		{
			[query setObject:(id)kSecAttrAccessibleAfterFirstUnlock forKey:(id)kSecAttrAccessible];
		}
		[query setObject:account forKey:(id)kSecAttrAccount];
		[query setObject:service forKey:(id)kSecAttrService];
		
		NSDictionary *update = [NSDictionary dictionaryWithObject:[password dataUsingEncoding:NSUTF8StringEncoding]
														   forKey:(id)kSecValueData];
		error = SecItemUpdate((CFDictionaryRef) query, (CFDictionaryRef) update);
	}
	else
	{
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		[info setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
		{
			[info setObject:(id)kSecAttrAccessibleAfterFirstUnlock forKey:(id)kSecAttrAccessible];
		}
		[info setObject:account forKey:(id)kSecAttrAccount];
		[info setObject:service forKey:(id)kSecAttrService];
		[info setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
		
		error = SecItemAdd((CFDictionaryRef) info, NULL);
	}
	
	if (errSecSuccess != error)
	{
		NSLog(@"Error setting password: %d", (int) error);
	}
}

- (void)erasePasswordForAccount:(NSString *)account service:(NSString *)service
{
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:account forKey:(id)kSecAttrAccount];
	[query setObject:service forKey:(id)kSecAttrService];
	
	OSStatus error = SecItemDelete((CFDictionaryRef) query);
	
	if (errSecSuccess != error)
	{
		NSLog(@"Error erasing password: %d", (int) error);
	}
}

@end
