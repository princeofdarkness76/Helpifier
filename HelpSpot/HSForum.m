#import "HSForum.h"
#import "HSWorkspace.h"
#import "HSXMLParser.h"

@interface HSWorkspace (private)

- (NSData *)_dataForMethod:(NSString *)method arguments:(NSDictionary *)args post:(BOOL)post error:(NSError **)error;

@end

@implementation HSForum

+ (NSArray *)forums:(NSError **)error
{
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"forums.list" arguments:nil post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"forum"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"forums", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSForum alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

+ (HSForum *)forumWithID:(unsigned int)forumID error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:forumID] forKey:@"xForumId"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"forums.get" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObject:@"forum"]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	HSForum *request = nil;
	NSDictionary *requestDict = [parser objectForData:data error:error];
	if (requestDict == nil) goto _error;
	
	request = [[[HSForum alloc] initWithContent:requestDict] autorelease];
	
_error:
	[parser release];
	return request;
}

- (unsigned int)forumID
{
	return [[content objectForKey:@"xForumId"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sForumName"];
}

- (unsigned int)order
{
	return [[content objectForKey:@"iOrder"] intValue];
}

- (NSString *)forumDescription
{
	return [content objectForKey:@"sDescription"];
}

- (BOOL)closed
{
	return [[content objectForKey:@"fClosed"] intValue];
}

- (NSArray *)topics:(NSError **)error
{
	return [self topicsInRange:NSMakeRange(NSNotFound, 0) error:error];
}

- (NSArray *)topicsInRange:(NSRange)range error:(NSError **)error
{
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:[self forumID]] forKey:@"xForumId"];
	if (range.location != NSNotFound)
	{
		[args setObject:[NSNumber numberWithUnsignedInt:range.location] forKey:@"start"];
		[args setObject:[NSNumber numberWithUnsignedInt:range.length] forKey:@"length"];
	}
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"forums.getTopics" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"topic"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"topics", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSForumTopic alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

- (BOOL)addTopicWithName:(NSString *)name from:(NSString *)poster body:(NSString *)body error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:[self forumID]], @"xForumId",
						  name, @"sTopic",
						  poster, @"sName",
						  body, @"tPost",
						  nil];
	
	return ([[HSWorkspace sharedWorkspace] _dataForMethod:@"forums.createTopic" arguments:args post:YES error:error] != nil);
}

@end


@implementation HSForumTopic

+ (NSArray *)topicsForQuery:(NSString *)query error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:query forKey:@"q"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"forums.search" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"topic"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"topics", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSForumTopic alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

- (unsigned int)topicID
{
	return [[content objectForKey:@"xTopicId"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sTopic"];
}

- (unsigned int)forumID
{
	return [[content objectForKey:@"xForumId"] intValue];
}

- (NSString *)forumName
{
	return [content objectForKey:@"sForumName"];
}

- (BOOL)closed
{
	return [[content objectForKey:@"fClosed"] intValue];
}

- (BOOL)sticky
{
	return [[content objectForKey:@"fSticky"] intValue];
}

- (NSDate *)posted
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTPosted"]];
}

- (NSString *)poster
{
	return [content objectForKey:@"sName"];
}

- (NSString *)link
{
	return [content objectForKey:@"link"];
}

- (NSString *)topicDescription
{
	return [content objectForKey:@"desc"];
}

- (unsigned int)numberOfPosts
{
	return [[content objectForKey:@"postcount"] intValue];
}

- (NSArray *)posts:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[self topicID]] forKey:@"xTopicId"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"forums.getPosts" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"post"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"posts", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSForumPost alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

- (BOOL)addPostFrom:(NSString *)poster body:(NSString *)body error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:[self topicID]], @"xTopicId",
						  poster, @"sName",
						  body, @"tPost",
						  nil];
	
	return ([[HSWorkspace sharedWorkspace] _dataForMethod:@"forums.createPost" arguments:args post:YES error:error] != nil);
}


@end


@implementation HSForumPost

- (unsigned int)postID
{
	return [[content objectForKey:@"xPostId"] intValue];
}

- (unsigned int)topicID
{
	return [[content objectForKey:@"xTopicId"] intValue];
}

- (NSDate *)posted
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTPosted"]];
}

- (NSString *)poster
{
	return [content objectForKey:@"sName"];
}

- (NSString *)body
{
	return [content objectForKey:@"tPost"];
}

- (NSString *)label
{
	return [content objectForKey:@"sLabel"];
}

- (NSURL *)url
{
	return [NSURL URLWithString:[content objectForKey:@"sURL"]];
}


@end


