#import "HSKnowledgeBook.h"
#import "HSWorkspace.h"
#import "HSXMLParser.h"

@interface HSWorkspace (private)

- (NSData *)_dataForMethod:(NSString *)method arguments:(NSDictionary *)args post:(BOOL)post error:(NSError **)error;

@end

@implementation HSKnowledgeBook

+ (NSArray *)books:(NSError **)error
{
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"kb.list" arguments:nil post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"book"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"books", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSKnowledgeBook alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

+ (HSKnowledgeBook *)bookWithID:(unsigned int)bookID error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:bookID] forKey:@"xBook"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"kb.get" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObject:@"book"]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	HSKnowledgeBook *request = nil;
	NSDictionary *requestDict = [parser objectForData:data error:error];
	if (requestDict == nil) goto _error;
	
	request = [[[HSKnowledgeBook alloc] initWithContent:requestDict] autorelease];
	
_error:
	[parser release];
	return request;
}

//
#pragma mark -
//

- (unsigned int)bookID
{
	return [[content objectForKey:@"xBook"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sBookName"];
}

- (unsigned int)order
{
	return [[content objectForKey:@"iOrder"] intValue];
}

- (NSString *)bookDescription
{
	return [content objectForKey:@"tDescription"];
}

- (NSArray *)tableOfContentsWithHTML:(BOOL)withHTML error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:[self bookID]], @"xBook",
						  [NSNumber numberWithBool:withHTML], @"fWithPageHTML",
						  nil];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"kb.getBookTOC" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"chapter", @"page", nil]];
	[parser setArrayElements:[NSArray arrayWithObjects:@"pages", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"toc", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSKnowledgeBookChapter alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

@end


@implementation HSKnowledgeBookChapter

- (NSString *)title
{
	return [content objectForKey:@"name"];
}

- (unsigned int)chapterID
{
	return [[content objectForKey:@"xChapter"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sChapterName"];
}

- (unsigned int)order
{
	return [[content objectForKey:@"iOrder"] intValue];
}

- (BOOL)appendix
{
	return [[content objectForKey:@"fAppendix"] intValue];
}

- (unsigned int)numberOfPages
{
	return [[content objectForKey:@"pages"] count];
}

- (HSKnowledgeBookPage *)pageAtIndex:(unsigned int)index
{
	NSArray *items = [content objectForKey:@"pages"];
	if (index >= [items count]) return nil;
	return [[[HSKnowledgeBookPage alloc] initWithContent:[items objectAtIndex:index]] autorelease];
}

@end



@implementation HSKnowledgeBookPage

+ (HSKnowledgeBookPage *)pageWithID:(unsigned int)pageID error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:pageID] forKey:@"xPage"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"kb.getPage" arguments:args post:NO error:error];
	if (data == nil) return nil;
		
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObject:@"page"]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	HSKnowledgeBookPage *request = nil;
	NSDictionary *requestDict = [parser objectForData:data error:error];
	if (requestDict == nil) goto _error;
	
	request = [[[HSKnowledgeBookPage alloc] initWithContent:requestDict] autorelease];
	
_error:
	[parser release];
	return request;
}

+ (NSArray *)pagesForQuery:(NSString *)query error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:query forKey:@"q"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"kb.search" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"page"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"pages", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSKnowledgeBookPage alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

- (void)voteIsHelpful:(BOOL)helpful error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:[self pageID]] forKey:@"xPage"];
	
	[[HSWorkspace sharedWorkspace] _dataForMethod:[NSString stringWithFormat:@"kb.vote%@Helpful", (helpful ? @"" : @"Not")]
										arguments:args
											 post:NO
											error:error];
}

- (unsigned int)pageID
{
	return [[content objectForKey:@"xPage"] intValue];
}

- (NSString *)title
{
	return [content objectForKey:@"name"];
}

- (unsigned int)chapterID
{
	return [[content objectForKey:@"xChapter"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sPageName"];
}

- (NSString *)body
{
	return [content objectForKey:@"tPage"];
}

- (unsigned int)order
{
	return [[content objectForKey:@"iOrder"] intValue];
}

- (BOOL)highlight
{
	return [[content objectForKey:@"fHighlight"] intValue];
}

- (BOOL)hidden
{
	return [[content objectForKey:@"fHidden"] intValue];
}

- (BOOL)private
{
	return [[content objectForKey:@"fPrivate"] intValue];
}

- (unsigned int)helpfulVotes
{
	return [[content objectForKey:@"iHelpful"] intValue];
}

- (unsigned int)notHelpfulVotes
{
	return [[content objectForKey:@"iNotHelpful"] intValue];
}

- (NSString *)link
{
	return [content objectForKey:@"link"];
}

- (NSString *)pageDescription
{
	return [content objectForKey:@"desc"];
}

- (NSString *)bookName
{
	return [content objectForKey:@"sBookName"];
}


@end

