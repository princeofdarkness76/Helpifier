#import "HSXMLParser.h"

@implementation HSXMLParser

- (id)init
{
	if (self = [super init])
	{
		dictionaryElements = [[NSMutableArray alloc] init];
		arrayElements = [[NSMutableArray alloc] init];
		ignoredElements = [[NSMutableArray alloc] init];
		ignoredContainers = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[root release];
	[dictionaryElements release];
	[arrayElements release];
	[ignoredElements release];
	[ignoredContainers release];
	[super dealloc];
}

+ (HSXMLParser *)parser
{
	return [[[HSXMLParser alloc] init] autorelease];
}

- (id)objectForData:(NSData *)data error:(NSError **)error
{
	familyTree = [[NSMutableArray alloc] init];
	parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	
	[root release];
	root = nil;
	
	if ([parser parse] == NO)
		if (error) *error = [parser parserError];
	[parser release];
	[familyTree release];
	familyTree = nil;
	
	return root;
}

//
#pragma mark SETUP
//

- (NSArray *)dictionaryElements
{
	return dictionaryElements;
}

- (void)setDictionaryElements:(NSArray *)a
{
	if (a == nil)
		[dictionaryElements removeAllObjects];
	else
		[dictionaryElements addObjectsFromArray:a];
}

- (NSArray *)arrayElements
{
	return arrayElements;
}

- (void)setArrayElements:(NSArray *)a
{
	if (a == nil)
		[arrayElements removeAllObjects];
	else
		[arrayElements addObjectsFromArray:a];
}

- (NSArray *)ignoredElements
{
	return ignoredElements;
}

- (void)setIgnoredElements:(NSArray *)a
{
	if (a == nil)
		[ignoredElements removeAllObjects];
	else
		[ignoredElements addObjectsFromArray:a];
}

- (NSArray *)ignoredContainers
{
	return ignoredContainers;
}

- (void)setIgnoredContainers:(NSArray *)a
{
	if (a == nil)
		[ignoredContainers removeAllObjects];
	else
		[ignoredContainers addObjectsFromArray:a];
}

- (Class)rootClass
{
	return rootClass;
}

- (void)setRootClass:(Class)c
{
	rootClass = c;
}

- (BOOL)makeKeysLowercase
{
	return lowercaseKeys;
}

- (void)setMakeKeysLowercase:(BOOL)u
{
	lowercaseKeys = u;
}

//
#pragma mark PARSING
//

- (id)currentParent
{
	return [familyTree lastObject];
}

- (void)pushChild:(id)a
{
	[familyTree addObject:a];
}

- (void)popChild
{
	[familyTree removeObjectAtIndex:[familyTree count] - 1];
}

- (void)addChildToCurrentParent:(id)obj forKey:(NSString *)key
{
	id p = [self currentParent];
	
	if ([p isKindOfClass:[NSDictionary class]])
		[p setObject:obj forKey:(lowercaseKeys ? [key lowercaseString] : key)];
	else if ([p isKindOfClass:[NSArray class]])
		[p addObject:obj];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([ignoredElements containsObject:elementName])
	{
	
	}
	else if ([dictionaryElements containsObject:elementName])
	{
		if (!root)
		{
			if (rootClass == nil) rootClass = [NSMutableDictionary class];
			root = [[rootClass alloc] init];
			[self pushChild:root];
		}
		NSMutableDictionary *p = [NSMutableDictionary dictionary];
		[self addChildToCurrentParent:p forKey:elementName];
		[self pushChild:p];
	}
	else if ([arrayElements containsObject:elementName])
	{
		if (!root)
		{
			if (rootClass == nil) rootClass = [NSMutableArray class];
			root = [[rootClass alloc] init];
			[self pushChild:root];
		}
		NSMutableArray *p = [NSMutableArray array];
		[self addChildToCurrentParent:p forKey:elementName];
		[self pushChild:p];
	}
	else if ([ignoredContainers containsObject:elementName])
	{
		isIgnoring++;
	}
	else
	{
		if (!root)
		{
			if (rootClass == nil) rootClass = [NSMutableDictionary class];
			root = [[rootClass alloc] init];
			[self pushChild:root];
		}
		element = [NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (isIgnoring > 0) return;
	
	NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
	NSString *content = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if ([content length] > 0)
		[element appendString:string];

	[subPool release];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{	
	if ([ignoredElements containsObject:elementName])
	{
	
	}
	else if ([dictionaryElements containsObject:elementName] || [arrayElements containsObject:elementName])
		[self popChild];
	else if ([ignoredContainers containsObject:elementName])
		isIgnoring--;
	else
	{
		if ([element length] > 0)
		{
			[self addChildToCurrentParent:element forKey:elementName];
			element = nil;
		}
	}
}

@end
