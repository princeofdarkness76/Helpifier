#import "HSWorkspace.h"
#import "HSRequest.h"
#import "HSPerson.h"
#import "HSXMLParser.h"
#import "NSURLRequest (AFExtension).h"
#import "NSData (AFExtension).h"
#import <unistd.h>

@interface HSWorkspace (internal)

- (NSData *)_dataForMethod:(NSString *)method arguments:(NSDictionary *)args post:(BOOL)post error:(NSError **)error;

@end

static HSWorkspace *sharedWorkspace = nil;

// private instance variables
static NSURL *baseURL;
static NSString *username, *password;
static unsigned int authenticationMethod;

static NSString *apiVersion;
static NSString *apiMinimumVersion;

static id _returnObj;
static NSMutableData *_gatheringData;
static BOOL _shouldKeepRunning;

@implementation HSWorkspace

+ (HSWorkspace *)sharedWorkspace
{
    return sharedWorkspace ? sharedWorkspace : [[self alloc] init];
}

- (id)init
{
	if (sharedWorkspace)
        [self dealloc];
    else
    {
        self = [super init];
		
		NSString *urlString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"HelpSpotBaseURL"];
		if (urlString == nil)
		{
			NSLog(@"HelpSpotBaseURL not found in the Info.plist");
			[self release];
			return nil;
		}
		baseURL = [[NSURL alloc] initWithString:urlString];
		authenticationMethod = NSNotFound;
		
		// try to detect the API version, keep it handy for wrapping methods, etc
		// (the host app shouldn't care about the version of the API, since we're wrapping it
		//	and presenting what's available to them in terms of available methods)
		// PERHAPS, just to speed up startup, just spawn a thread with this? Let it populate when it populates it, no rush...
		NSData *data = [self _dataForMethod:@"version" arguments:nil post:NO error:nil];
		
		HSXMLParser *parser = [[HSXMLParser alloc] init];
		[parser setIgnoredElements:[NSArray arrayWithObjects:@"results", nil]];
		[parser setRootClass:[NSMutableDictionary class]];
		
		NSDictionary *resultDict = [parser objectForData:data error:nil];
		if (resultDict != nil)
		{
			apiVersion = [[resultDict objectForKey:@"version"] retain];
			apiMinimumVersion = [[resultDict objectForKey:@"min_version"] retain];
		}
		
        sharedWorkspace = self;
    }
	
    return sharedWorkspace;
}

- (NSURL *)url
{
	return baseURL;
}

- (void)setAuthenticationUsername:(NSString *)u
						 password:(NSString *)p
						   method:(unsigned int)m
{
	[username release];
	username = [u retain];
	
	[password release];
	password = [p retain];
	
	authenticationMethod = m;
}

- (unsigned int)authenticationMethod
{
	return authenticationMethod;
}

//
#pragma mark AUTHENTICATED USER
//

- (HSPerson *)user:(NSError **)error
{
	NSData *data = [self _dataForMethod:@"private.user.preferences" arguments:nil post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"preferences", nil]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	HSPerson *result = nil;
	NSDictionary *resultDict = [parser objectForData:data error:error];
	if (resultDict == nil) goto _error;
	
	result = [[[HSPerson alloc] initWithContent:resultDict] autorelease];
	
_error:
	[parser release];
	return result;
}

//
#pragma mark LISTS
//

- (NSArray *)categories:(NSError **)error
{
	NSString *method;
	
	if (authenticationMethod == NSNotFound)
		method = @"request.getCategories";
	else
		method = @"private.request.getCategories";
	
	NSData *data = [self _dataForMethod:method arguments:nil post:NO error:error];
	if (data == nil) return nil;
		
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"category", @"person", @"tag", nil]];
	[parser setArrayElements:[NSArray arrayWithObjects:@"sCustomFieldList", @"sPersonList", @"reportingTags", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"categories", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
	{
		if ([resultDict count] > 0)
			[result addObject:[[[HSCategory alloc] initWithContent:resultDict] autorelease]];
	}

_error:
	[parser release];
	return result;
}

- (NSArray *)customFields:(NSError **)error
{
	NSString *method;
	
	if (authenticationMethod == NSNotFound)
		method = @"request.getCustomFields";
	else
		method = @"private.request.getCustomFields";
	
	NSData *data = [self _dataForMethod:method arguments:nil post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"field"]];
	[parser setArrayElements:[NSArray arrayWithObjects:@"listItems", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"customfields", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSCustomField alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

- (NSDictionary *)labels:(NSError **)error
{
	NSString *method;
	
	if (authenticationMethod == NSNotFound)
		method = @"util.getFieldLabels";
	else
		method = @"private.filter.getColumnNames";
	
	NSData *data = [self _dataForMethod:method arguments:nil post:NO error:error];
	if (data == nil) return nil;

	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"labels", nil]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	NSMutableDictionary *result = nil;
	NSDictionary *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	result = [NSMutableDictionary dictionary];
	[result addEntriesFromDictionary:resultDicts];
	
_error:
	[parser release];
	return result;
}

- (NSArray *)staff:(NSError **)error
{
	NSData *data = [self _dataForMethod:@"private.util.getActiveStaff" arguments:nil post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"person"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"staff", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSPerson alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

- (NSArray *)mailboxes:(BOOL)activeOnly error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:activeOnly] forKey:@"fActiveOnly"];
	NSData *data = [self _dataForMethod:@"private.request.getMailboxes" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObject:@"mailbox"]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"results", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSMailbox alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

//
#pragma mark PASSWORDS
//

- (NSString *)passwordForEmail:(NSString *)email error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:email forKey:@"sEmail"];
	
	NSData *data = [self _dataForMethod:@"private.customer.getPasswordByEmail" arguments:args post:NO error:error];
	if (data == nil) return nil;
		
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"results", nil]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	NSString *result = nil;
	NSDictionary *resultDict = [parser objectForData:data error:error];
	if (resultDict == nil) goto _error;
	
	result = [resultDict objectForKey:@"sPassword"];
	
_error:
	[parser release];
	return result;
}

- (BOOL)setPassword:(NSString *)pwd forEmail:(NSString *)email error:(NSError **)error
{	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
						  email, @"sEmail",
						  pwd, @"sPassword",
						  nil];
	
	if ([self _dataForMethod:@"private.customer.setPasswordByEmail" arguments:args post:NO error:error] == nil) return NO;
		
	return YES;
}

//
#pragma mark -
//

- (NSData *)_dataForMethod:(NSString *)method arguments:(NSDictionary *)args post:(BOOL)post error:(NSError **)error
{
	if (authenticationMethod == NSNotFound && [method hasPrefix:@"private"])
	{
		if (error)
			*error = [NSError errorWithDomain:@"HSErrorDomain"
										 code:-5
									 userInfo:[NSDictionary
											   dictionaryWithObject:@"Method requires authentication"
											   forKey:NSLocalizedDescriptionKey]];
		
		return nil;
	}
	
	NSMutableString *parameters = [NSMutableString stringWithFormat:@"?method=%@", method];
	
	if (post == NO)
	{
		NSEnumerator *e = [args keyEnumerator];
		NSString *key;
		
		while (key = [e nextObject])
			[parameters appendFormat:@"&%@=%@", key, [args objectForKey:key]];
	}
	
	if (authenticationMethod == HSAuthenticationMethodURL && [method hasPrefix:@"private"])
		[parameters appendFormat:@"&username=%@&password=%@", username, password];
	
	NSURL *url = [NSURL URLWithString:parameters relativeToURL:baseURL];
	NSURLRequest *urlRequest;
	
	if (post)
		urlRequest = [NSURLRequest requestWithURL:url multipartForm:args];
	else
		urlRequest = [NSURLRequest requestWithURL:url];

	_returnObj = nil;
	[NSThread detachNewThreadSelector:@selector(startRequest:) toTarget:self withObject:urlRequest];
	while (_returnObj == nil) usleep(10); // just hang out for a sec
	
	if ([_returnObj isKindOfClass:[NSError class]])
	{
		if (error)
			*error = [_returnObj autorelease];
		return nil;
	}
	
	if ([_returnObj isKindOfClass:[NSData class]] == NO) return nil; // what the fuck did you just return, then?
	
	NSData *data = [_returnObj autorelease];
	if ([data length] == 0) return nil;
		
	if (memcmp([data bytes], "<?xml", 5) != 0)
	{
		if (error)
			*error = [NSError errorWithDomain:@"HSErrorDomain"
										 code:-1
									 userInfo:[NSDictionary
											   dictionaryWithObject:@"Reply is not XML format"
											   forKey:NSLocalizedDescriptionKey]];

		return nil;
	}
	
	if (strnstr([data bytes], "<errors>", [data length]) != nil)
	{
		HSXMLParser *parser = [[HSXMLParser alloc] init];
		[parser setIgnoredElements:[NSArray arrayWithObjects:@"errors", nil]];
		[parser setDictionaryElements:[NSArray arrayWithObjects:@"error", nil]];
		[parser setRootClass:[NSMutableArray class]];

		NSArray *errors = [parser objectForData:data error:error];
		if (errors == nil) return nil;
		
		if (error)
			*error = [NSError errorWithDomain:@"HSErrorDomain"
										 code:[[[errors objectAtIndex:0] objectForKey:@"id"] intValue]
									 userInfo:[NSDictionary
											   dictionaryWithObject:[[errors objectAtIndex:0] objectForKey:@"description"]
															 forKey:NSLocalizedDescriptionKey]];

		return nil;
	}
	
	return data;
}

- (void)startRequest:(NSURLRequest *)request
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

	_gatheringData = nil;
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

	if (connection == nil)
	{
		_returnObj = [[NSError alloc] initWithDomain:@"HSErrorDomain"
												code:-6
											userInfo:[NSDictionary
													  dictionaryWithObject:@"Connection could not be created"
													  forKey:NSLocalizedDescriptionKey]];
	}
	else
	{
		_shouldKeepRunning = YES;
		while (_shouldKeepRunning && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	}
	
	[pool release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_shouldKeepRunning = NO;
	_returnObj = [error retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([username length] != 0 && [password length] != 0 && [challenge previousFailureCount] == 0)
	{
		NSURLCredential *credential = [NSURLCredential credentialWithUser:username
																 password:password
															  persistence:NSURLCredentialPersistenceNone];
			
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	}
	else
		[[challenge sender] cancelAuthenticationChallenge:challenge];

}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	_shouldKeepRunning = NO;
	_returnObj = [[challenge error] retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (_gatheringData == nil)
		_gatheringData = [[NSMutableData alloc] init];
	
	[_gatheringData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	_shouldKeepRunning = NO;
	_returnObj = _gatheringData;
}

@end

//
#pragma mark -
//

@implementation HSCategory

- (unsigned int)categoryID
{
	return [[content objectForKey:@"xCategory"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sCategory"];
}

- (NSIndexSet *)customFieldIDs
{
	NSMutableIndexSet *fields = [NSMutableIndexSet indexSet];
	
	NSEnumerator *e = [[content objectForKey:@"sCustomFieldList"] objectEnumerator];
	NSString *field;
	
	while (field = [e nextObject])
		[fields addIndex:[field intValue]];
	
	return fields;
}

- (BOOL)deleted
{
	return [[content objectForKey:@"fDeleted"] intValue];
}

- (BOOL)allowPublicSubmit
{
	return [[content objectForKey:@"fAllowPublicSubmit"] intValue];
}

- (unsigned int)defaultPersonID
{
	return [[content objectForKey:@"xPersonDefault"] intValue];
}

- (BOOL)autoAssign
{
	return [[content objectForKey:@"fAutoAssignTo"] intValue];
}

- (NSArray *)persons
{
	NSMutableArray *array = [NSMutableArray array];
	NSEnumerator *e = [[content objectForKey:@"sPersonList"] objectEnumerator];
	NSDictionary *person;
	
	while (person = [e nextObject])
		[array addObject:[[[HSPerson alloc] initWithContent:person] autorelease]];
	
	return array;
}

- (NSArray *)reportingTags
{
	NSMutableArray *array = [NSMutableArray array];
	NSEnumerator *e = [[content objectForKey:@"reportingTags"] objectEnumerator];
	NSDictionary *tag;
	
	while (tag = [e nextObject])
		[array addObject:[[[HSReportingTag alloc] initWithContent:tag] autorelease]];
	
	return array;
}

@end

@implementation HSCustomField

- (unsigned int)fieldID
{
	return [[content objectForKey:@"xCustomField"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"fieldName"];
}

- (NSString *)type
{
	// select, text, numtext, checkbox, ajax, etc
	return [content objectForKey:@"fieldType"];
}

- (BOOL)isAlwaysVisible
{
	return [[content objectForKey:@"isAlwaysVisible"] intValue];
}

- (BOOL)isRequired
{
	return [[content objectForKey:@"isRequired"] intValue];
}

- (BOOL)isPublic
{
	id obj = [content objectForKey:@"isPublic"];
	return (obj ? [obj intValue] : YES);
}

- (NSArray *)listItems
{
	return [content objectForKey:@"listItems"];
}

- (unsigned int)order
{
	return [[content objectForKey:@"iOrder"] intValue];
}

- (unsigned int)decimalPlaces
{
	return [[content objectForKey:@"iDecimalPlaces"] intValue];
}

- (NSURL *)ajaxURL
{
	id obj = [content objectForKey:@"sAjaxUrl"];
	return (obj ? [NSURL URLWithString:obj relativeToURL:nil] : nil);
}

- (NSString *)regex
{
	return [content objectForKey:@"sRegex"];
}

- (unsigned int)textFieldSize
{
	return [[content objectForKey:@"sTxtSize"] intValue];
}

- (unsigned int)largeTextFieldRows
{
	return [[content objectForKey:@"lrgTextRows"] intValue];
}

@end


@implementation HSMailbox

- (unsigned int)mailboxID
{
	return [[content objectForKey:@"xMailbox"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sReplyName"];
}

- (NSString *)email
{
	return [content objectForKey:@"sReplyEmail"];
}


@end


@implementation HSReportingTag

- (unsigned int)reportingTagID
{
	return [[content objectForKey:@"xReportingTag"] intValue];
}

- (NSString *)name
{
	return [content objectForKey:@"sReportingTag"];
}

@end


