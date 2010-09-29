#import "HSFilter.h"
#import "HSWorkspace.h"
#import "HSRequest.h"
#import "HSXMLParser.h"

@interface HSWorkspace (private)

- (NSData *)_dataForMethod:(NSString *)method arguments:(NSDictionary *)args post:(BOOL)post error:(NSError **)error;

@end

@implementation HSFilter

+ (NSArray *)filters:(NSError **)error
{
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"private.user.getFilters" arguments:nil post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"filter", @"displayColumns", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"filters", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSFilter alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

- (unsigned int)filterID
{
	return [[content objectForKey:@"xFilter"] intValue];
}

- (NSString *)filterIDString
{
	return [content objectForKey:@"xFilter"];
}

- (NSString *)filterName
{
	return [content objectForKey:@"sFilterName"];
}

- (NSString *)folder
{
	return [content objectForKey:@"sFilterFolder"];
}

- (NSDictionary *)columns
{
	return [content objectForKey:@"displayColumns"];
}

- (BOOL)global
{
	return [[content objectForKey:@"fGlobal"] intValue];
}

- (unsigned int)count
{
	return [[content objectForKey:@"count"] intValue];
}

- (unsigned int)unread
{
	return [[content objectForKey:@"unread"] intValue];
}

- (NSArray *)requests:(NSError **)error
{
	return [self requestsInRange:NSMakeRange(NSNotFound, 0) error:error];
}

- (NSArray *)requestsInRange:(NSRange)range error:(NSError **)error
{
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObject:[self filterIDString] forKey:@"xFilter"];
	if (range.location != NSNotFound)
	{
		[args setObject:[NSNumber numberWithUnsignedInt:range.location] forKey:@"start"];
		[args setObject:[NSNumber numberWithUnsignedInt:range.length] forKey:@"length"];
	}

	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"private.filter.get" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"request"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"filter", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSRequest alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

@end
