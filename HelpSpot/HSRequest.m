#import "HSRequest.h"
#import "HSWorkspace.h"
#import "HSPerson.h"
#import "HSTimeEvent.h"
#import "NSURLRequest (AFExtension).h"
#import "NSData (AFExtension).h"
#import "HSXMLParser.h"

@interface HSWorkspace (private)

- (NSData *)_dataForMethod:(NSString *)method arguments:(NSDictionary *)args post:(BOOL)post error:(NSError **)error;

@end

@implementation HSRequestDescription

+ (NSArray *)descriptionsForEmail:(NSString *)email password:(NSString *)pwd error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
						  email, @"sEmail",
						  pwd, @"sPassword",
						  nil];

	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"customer.getRequests" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"request", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"requests", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *descriptions = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	descriptions = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[descriptions addObject:[HSRequestDescription descriptionWithContent:resultDict]];
	
_error:
	[parser release];
	return descriptions;
}

+ (HSRequestDescription *)descriptionWithContent:(NSDictionary *)c
{
	return [[[HSRequestDescription alloc] initWithContent:c] autorelease];
}

- (unsigned int)requestID
{
	return [[content objectForKey:@"xRequest"] intValue];
}

- (NSString *)accessKey
{
	return [content objectForKey:@"accesskey"];
}

- (BOOL)isOpen
{
	return [[content objectForKey:@"fOpen"] intValue];
}

- (unsigned int)status
{
	return [[content objectForKey:@"xStatus"] intValue];
}

- (BOOL)urgent
{
	return [[content objectForKey:@"fUrgent"] intValue];
}

- (NSArray *)timeEvents:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[self requestID]] forKey:@"xRequest"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"private.request.getTimeEvents" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"event", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"time_events", nil]];
	[parser setRootClass:[NSMutableArray class]];
	
	NSMutableArray *result = nil;
	NSArray *resultDicts = [parser objectForData:data error:error];
	if (resultDicts == nil) goto _error;
	
	NSEnumerator *e = [resultDicts objectEnumerator];
	NSDictionary *resultDict;
	
	result = [NSMutableArray array];
	while (resultDict = [e nextObject])
		[result addObject:[[[HSTimeEvent alloc] initWithContent:resultDict] autorelease]];
	
_error:
	[parser release];
	return result;
}

@end


@implementation HSRequest

+ (HSRequest *)requestWithID:(unsigned int)requestID error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:requestID] forKey:@"xRequest"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"private.request.get" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"item", @"file", nil]];
	[parser setArrayElements:[NSArray arrayWithObjects:@"request_history", @"files", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"request", nil]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	HSRequest *request = nil;
	NSDictionary *requestDict = [parser objectForData:data error:error];
	if (requestDict == nil) goto _error;
	
	request = [[[HSRequest alloc] initWithContent:requestDict] autorelease];
	
_error:
	[parser release];
	return request;
}

+ (HSRequest *)requestForAccessKey:(NSString *)accessKey error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:accessKey forKey:@"accesskey"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"request.get" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"item", @"file", nil]];
	[parser setArrayElements:[NSArray arrayWithObjects:@"request_history", @"files", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"request", nil]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	HSRequest *request = nil;
	NSDictionary *requestDict = [parser objectForData:data error:error];
	if (requestDict == nil) goto _error;
	
	request = [[[HSRequest alloc] initWithContent:requestDict] autorelease];
	
_error:
	[parser release];
	return request;
}

+ (NSArray *)requestsForQuery:(NSString *)query error:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:query forKey:@"sSearch"];
	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"private.request.search" arguments:args post:NO error:error];
	if (data == nil) return nil;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setDictionaryElements:[NSArray arrayWithObjects:@"request", nil]];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"requests", nil]];
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

+ (HSRequest *)request
{
	return [[[HSRequest alloc] init] autorelease];
}

- (id)init
{
	self = [super init];
	
	fileNumber = 1;
	
	return self;
}

//
#pragma mark ACTION
//

- (BOOL)add:(NSError **)error
{
	if ([[self body] length] == 0)
	{
		if (error)
			*error = [NSError errorWithDomain:@"HSErrorDomain"
										 code:-2
									 userInfo:[NSDictionary
											   dictionaryWithObject:@"Request body is empty"
											   forKey:NSLocalizedDescriptionKey]];
		return NO;
	}
	
	if ([[self firstName] length] == 0 &&
		[[self lastName] length] == 0 &&
		[self userID] == 0 &&
		[[self email] length] == 0 &&
		[[self phone] length] == 0)
	{
		if (error)
			*error = [NSError errorWithDomain:@"HSErrorDomain"
										 code:-3
									 userInfo:[NSDictionary
											   dictionaryWithObject:@"Not enough information in request"
											   forKey:NSLocalizedDescriptionKey]];
		return NO;
	}
	
	NSString *method;
	
	if ([[HSWorkspace sharedWorkspace] authenticationMethod] == NSNotFound)
		method = @"request.create";
	else
		method = @"private.request.create";

	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:method arguments:content post:YES error:error];
	if (data == nil) return NO;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"request", nil]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	BOOL success = NO;
	NSDictionary *result = [parser objectForData:data error:error];
	if (result == nil) goto _error;
	
	[self setRequestID:[[result objectForKey:@"xRequest"] intValue]];
	[self setAccessKey:[result objectForKey:@"accesskey"]];
	
	success = YES;
	
_error:
	[parser release];
	return success;
}

- (BOOL)update:(NSError **)error
{
	if ([[self body] length] == 0)
	{
		if (error)
			*error = [NSError errorWithDomain:@"HSErrorDomain"
										 code:-2
									 userInfo:[NSDictionary
											   dictionaryWithObject:@"Request body is empty"
											   forKey:NSLocalizedDescriptionKey]];
		return NO;
	}
	
	NSString *method;
	
	if ([[HSWorkspace sharedWorkspace] authenticationMethod] == NSNotFound)
	{
		if ([[self accessKey] length] == 0)
		{
			if (error)
				*error = [NSError errorWithDomain:@"HSErrorDomain"
											 code:-3
										 userInfo:[NSDictionary
												   dictionaryWithObject:@"Not enough information in request"
												   forKey:NSLocalizedDescriptionKey]];
			return NO;
		}
		
		method = @"request.update";
	}
	else
	{
		if ([self requestID] == 0)
		{
			if (error)
				*error = [NSError errorWithDomain:@"HSErrorDomain"
											 code:-3
										 userInfo:[NSDictionary
												   dictionaryWithObject:@"Not enough information in request"
												   forKey:NSLocalizedDescriptionKey]];
			return NO;
		}

		method = @"private.request.update";
	}

	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:method arguments:content post:YES error:error];
	if (data == nil) return NO;
	
	HSXMLParser *parser = [[HSXMLParser alloc] init];
	[parser setIgnoredElements:[NSArray arrayWithObjects:@"request", nil]];
	[parser setRootClass:[NSMutableDictionary class]];
	
	BOOL success = ([parser objectForData:data error:error] != nil);
	
	[parser release];
	return success;
}

- (BOOL)addTimeTrackerEvent:(NSString *)description date:(NSDate *)date personID:(unsigned int)personID length:(double)seconds error:(NSError **)error
{
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:[self requestID]], @"xRequest",
						  [NSNumber numberWithInt:personID], @"xPerson",
						  [NSNumber numberWithInt:[components year]], @"iYear",
						  [NSNumber numberWithInt:[components month]], @"iMonth",
						  [NSNumber numberWithInt:[components day]], @"iDay",
						  description, @"tDescription",
						  [NSString stringWithFormat:@"%.1f", seconds / 3600], @"tTime",
						  nil];
	
	return ([[HSWorkspace sharedWorkspace] _dataForMethod:@"private.request.addTimeEvent" arguments:args post:YES error:error] != nil);
}

- (void) get
{
    NSError *error = nil;
    BOOL isUnread = [self isUnread];
    int previousHistoryItems = [self numberOfHistoryItems];
    HSRequest *fullRequest = [HSRequest requestWithID:[self requestID] error:&error];
    if (fullRequest != nil)
    {
        @synchronized (self)
        {
            [content release];
            content = [[fullRequest content] retain];
            [self setIsUnread:isUnread];
            if ([self numberOfHistoryItems] != previousHistoryItems)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HSRequestDidUpdateNotification" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[self requestID]], @"requestID", nil]];
        }
    }
}

//
#pragma mark ACCESS
//

- (void)setRequestID:(unsigned int)r
{
	[content setObject:[NSNumber numberWithUnsignedInt:r] forKey:@"xRequest"];
}

- (void)setAccessKey:(NSString *)k
{
	[content setValue:k forKey:@"accesskey"];
}

- (unsigned int)userID
{
	return [[content objectForKey:@"sUserID"] intValue];
}

- (void)setUserID:(unsigned int)userID
{
	[content setObject:[NSNumber numberWithUnsignedInt:userID] forKey:@"sUserID"];
}

- (NSString *)firstName
{
	return [content objectForKey:@"sFirstName"];
}

- (void)setFirstName:(NSString *)name
{
	[content setValue:name forKey:@"sFirstName"];
}

- (NSString *)lastName
{
	return [content objectForKey:@"sLastName"];
}

- (void)setLastName:(NSString *)name
{
	[content setValue:name forKey:@"sLastName"];
}

- (NSString *)fullName
{
	return [content objectForKey:@"fullname"];
}

- (NSString *)email
{
	return [content objectForKey:@"sEmail"];
}

- (void)setEmail:(NSString *)email
{
	[content setValue:email forKey:@"sEmail"];
}

- (NSString *)phone
{
	return [content objectForKey:@"sPhone"];
}

- (void)setPhone:(NSString *)phone
{
	[content setValue:phone forKey:@"sPhone"];
}

- (NSString *)body
{
	return [content objectForKey:@"tNote"];
}

- (void)setBody:(NSString *)body
{
	[content setValue:body forKey:@"tNote"];
}

- (NSAttributedString *)bodyAttributedString
{
	NSDictionary *attrs = [NSDictionary dictionary];
	NSAttributedString *as = [[[NSAttributedString alloc] initWithHTML:[NSData dataWithBytes:[[self body] UTF8String] length:[[self body] length]] documentAttributes:&attrs] autorelease];
	return as;
}

- (void) setBodyAttributedString:(NSAttributedString *)b
{
	[self setBody:[b string]];
}

- (NSString *)category
{
	return [content objectForKey:@"xCategory"];
}

- (void)setCategoryID:(unsigned int)catID
{
	[content setObject:[NSNumber numberWithInt:catID] forKey:@"xCategory"];
}

- (NSString *)valueForCustomField:(unsigned int)field
{
	return [content objectForKey:[NSString stringWithFormat:@"Custom%d", field]];
}

- (void)setValue:(NSString *)value forCustomField:(unsigned int)field
{
	[content setValue:value forKey:[NSString stringWithFormat:@"Custom%d", field]];
}

- (NSString *)valueForKey:(NSString *)key
{
	return [content valueForKey:key];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key
{
	[content setValue:value forKey:key];
}

- (unsigned int)type
{
	return [[content objectForKey:@"fNoteType"] intValue];
}

- (void)setType:(unsigned int)t
{
	[content setObject:[NSNumber numberWithUnsignedInt:t] forKey:@"fNoteType"];
}

- (void)setIsOpen:(BOOL)o
{
	[content setObject:[NSNumber numberWithBool:o] forKey:@"fOpen"];
}

- (void)setStatus:(unsigned int)x
{
	[content setObject:[NSNumber numberWithUnsignedInt:x] forKey:@"xStatus"];
}

- (void)setUrgent:(BOOL)u
{
	[content setObject:[NSNumber numberWithBool:u] forKey:@"fUrgent"];
}

- (BOOL)isUnread
{
	return [[content objectForKey:@"isUnread"] boolValue];
}

- (void)setIsUnread:(BOOL)u
{
	[content setObject:[NSNumber numberWithBool:u] forKey:@"isUnread"];
}

- (NSString *)openedVia
{
	return [content objectForKey:@"fOpenedVia"];
}

- (void)setOpenedVia:(NSString *)o
{
	[content setObject:o forKey:@"fOpenedVia"];
}

- (unsigned int)openedViaID
{
	return [[content objectForKey:@"xOpenedViaId"] intValue];
}

- (NSString *)openedBy
{
	return [content objectForKey:@"xPersonOpenedBy"];
}

- (NSString *)assignedTo
{
	return [content objectForKey:@"xPersonAssignedTo"];
}

- (void)setAssignedTo:(NSString *)a
{
	[content setObject:a forKey:@"xPersonAssignedTo"];
}

- (NSDate *)opened
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTOpened"]];
}

- (void)setOpened:(NSDate *)d
{
	[content setObject:[NSNumber numberWithDouble:[d timeIntervalSince1970]] forKey:@"dtGMTOpened"];
}

- (NSDate *)closed
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTClosed"]];
}

- (NSString *)password
{
	return [content objectForKey:@"sRequestPassword"];
}

- (NSString *)title
{
	return [content objectForKey:@"sTitle"];
}

- (void)setTitle:(NSString *)t
{
	[content setObject:t forKey:@"sTitle"];
}

- (NSString *)lastReplyBy
{
	return [content objectForKey:@"iLastReplyBy"];
}

- (BOOL)trash
{
	return [[content objectForKey:@"fTrash"] intValue];
}

- (void)setTrash:(BOOL)f
{
	[content setObject:[NSNumber numberWithBool:f] forKey:@"fTrash"];
}

- (NSDate *)trashed
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTTrashed"]];
}

- (void)setReportingTags:(NSArray *)reportingTags
{
	NSMutableString *tagsString = [NSMutableString string];
	NSEnumerator *e = [reportingTags objectEnumerator];
	HSReportingTag *tag;
	
	while (tag = [e nextObject])
		[tagsString appendFormat:@"%@%d", ([tagsString length] > 0 ? @"," : @""), [tag reportingTagID]];
	
	[content setObject:tagsString forKey:@"reportingTags"];
}

- (void)setFromMailbox:(HSMailbox *)mailbox
{
	[content setObject:[NSNumber numberWithInt:[mailbox mailboxID]] forKey:@"email_from"];
}

- (void)setEmailCC:(NSArray *)emails
{
	NSMutableString *emailString = [NSMutableString string];
	NSEnumerator *e = [emails objectEnumerator];
	NSString *email;
	
	while (email = [e nextObject])
		[emailString appendFormat:@"%@%@", ([emailString length] > 0 ? @"," : @""), email];
	
	[content setObject:emailString forKey:@"email_cc"];
}

- (void)setEmailBCC:(NSArray *)emails
{
	NSMutableString *emailString = [NSMutableString string];
	NSEnumerator *e = [emails objectEnumerator];
	NSString *email;
	
	while (email = [e nextObject])
		[emailString appendFormat:@"%@%@", ([emailString length] > 0 ? @"," : @""), email];
	
	[content setObject:emailString forKey:@"email_bcc"];
}

- (void)setEmailTo:(NSArray *)emails
{
	NSMutableString *emailString = [NSMutableString string];
	NSEnumerator *e = [emails objectEnumerator];
	NSString *email;
	
	while (email = [e nextObject])
		[emailString appendFormat:@"%@%@", ([emailString length] > 0 ? @"," : @""), email];
	
	[content setObject:emailString forKey:@"email_to"];
}

- (void)setEmailStaff:(NSArray *)persons
{
	NSMutableString *personsString = [NSMutableString string];
	NSEnumerator *e = [persons objectEnumerator];
	HSPerson *person;
	
	while (person = [e nextObject])
		[personsString appendFormat:@"%@%d", ([personsString length] > 0 ? @"," : @""), [person personID]];
	
	[content setObject:personsString forKey:@"email_staff"];
}

- (void)addFileWithName:(NSString *)name mimeType:(NSString *)type content:(NSData *)data
{
	[content setObject:name forKey:[NSString stringWithFormat:@"File%d_sFilename", fileNumber]];
	[content setObject:type forKey:[NSString stringWithFormat:@"File%d_sFileMimeType", fileNumber]];
	[content setObject:[data encodeBase64] forKey:[NSString stringWithFormat:@"File%d_bFileBody", fileNumber]];
	
	fileNumber++;
}

- (unsigned int)numberOfHistoryItems
{
	return [[content objectForKey:@"request_history"] count];
}

- (HSRequestHistoryItem *)historyItemAtIndex:(unsigned int)index
{
	NSArray *items = [content objectForKey:@"request_history"];
	if (index >= [items count]) return nil;
	return [[[HSRequestHistoryItem alloc] initWithContent:[items objectAtIndex:index]] autorelease];
}

@end

@implementation HSRequestHistoryItem

- (unsigned int)requestHistoryItemID
{
	return [[content objectForKey:@"xRequestHistory"] intValue];
}

- (unsigned int)requestID
{
	return [[content objectForKey:@"xRequest"] intValue];
}

- (NSString *)fullName
{
	return [content objectForKey:@"xPerson"];
}

- (NSString *)firstName
{
	return [content objectForKey:@"firstname"];
}

- (NSString *)body
{
	return [content objectForKey:@"tNote"];
}

- (NSString *)log
{
	return [content objectForKey:@"tLog"];
}

- (NSDate *)date
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%B %d %Y, %I:%M %p" allowNaturalLanguage:YES] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTChange"]];
}

- (NSString *)emailHeaders
{
	return [content objectForKey:@"tEmailHeaders"];
}

- (BOOL)public
{
	id obj = [content objectForKey:@"fPublic"];
	return (obj ? [obj intValue] : YES);
}

- (BOOL)initial
{
	return [[content objectForKey:@"fInitial"] intValue];
}

- (BOOL)isHTML
{
	return [[content objectForKey:@"fNoteIsHTML"] intValue];
}

- (BOOL)merged
{
	return [[content objectForKey:@"fMergedFromRequest"] intValue];
}

- (unsigned int)numberOfAttachments
{
	return [[content objectForKey:@"files"] count];
}

- (HSRequestAttachment *)attachmentAtIndex:(unsigned int)index
{
	NSArray *items = [content objectForKey:@"files"];
	if (index >= [items count]) return nil;
	return [[[HSRequestAttachment alloc] initWithContent:[items objectAtIndex:index]] autorelease];
}

@end

@implementation HSRequestAttachment

- (NSString *)filename
{
	return [content objectForKey:@"sFilename"];
}

- (NSString *)mimeType
{
	return [content objectForKey:@"sFileMimeType"];
}

- (NSURL *)url
{
	id obj = [content objectForKey:@"public_url"];
	if (!obj) obj = [content objectForKey:@"url"];
	return [NSURL URLWithString:obj];
}

- (NSURL *)privateURL
{
	return [NSURL URLWithString:[content objectForKey:@"private_url"]];
}

- (unsigned int)attachmentID
{
	return [[content objectForKey:@"xDocumentId"] intValue];
}

@end


