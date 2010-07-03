#import "PDEntryParser.h"


@implementation PDEntryParser

- (NSDictionary *)parseEntry:(NSScanner *)scanner
{
	if (![scanner scanString:@"[" intoString:NULL])
	{
		// if we don't have this, it's not an entry.
		return nil;
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NSString *scanned;
	[scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"_X"]
						intoString:&scanned];
	
	if ([scanned isEqualToString:@"_"])
	{
		[dict setObject:[NSNumber numberWithBool:NO] forKey:@"checked"];
	}
	else if ([scanned isEqualToString:@"X"])
	{
		[dict setObject:[NSNumber numberWithBool:YES] forKey:@"checked"];
	}
	
	[scanner scanString:@"] " intoString:NULL];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&scanned];
	[dict setObject:[scanned stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
			 forKey:@"text"];
	
	if ([scanner scanUpToString:@"[" intoString:&scanned])
	{
		[dict setObject:[scanned stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
				 forKey:@"comment"];
	}
	
	return dict;
}

@end
