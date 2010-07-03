#import "PDListParser.h"

#import "PDEntryParser.h"

@implementation PDListParser

- (NSArray *)parseListEntriesFromString:(NSString *)importText
{
	NSMutableArray *entries = [NSMutableArray array];
	
	NSScanner *scanner = [NSScanner scannerWithString:importText];
	
	// skip everything until the first list entry.
	[scanner scanUpToString:@"[" intoString:NULL];
	
	NSDictionary *parsedEntry;
	PDEntryParser *entryParser = [[PDEntryParser alloc] init];
	
	while ((parsedEntry = [entryParser parseEntry:scanner]))
	{
		[entries addObject:parsedEntry];
	}
	
	[entryParser release];
	
	return entries;
}

@end
