#import "HSTimeEvent.h"
#import "HSWorkspace.h"
#import "HSXMLParser.h"

@interface HSWorkspace (private)

- (NSData *)_dataForMethod:(NSString *)method arguments:(NSDictionary *)args post:(BOOL)post error:(NSError **)error;

@end

@interface HSItem (private)

- (NSDictionary *)_content;

@end

@implementation HSTimeEvent

+ (NSArray *)timeEventsForQuery:(HSTimeEventQuery *)query error:(NSError **)error
{	
	NSData *data = [[HSWorkspace sharedWorkspace] _dataForMethod:@"private.timetracker.search" arguments:[query _content] post:NO error:error];
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

- (BOOL)delete:(NSError **)error
{
	NSDictionary *args = [NSDictionary dictionaryWithObject:[content objectForKey:@"xTimeId"] forKey:@"xTimeId"];

	return ([[HSWorkspace sharedWorkspace] _dataForMethod:@"private.request.deleteTimeEvent" arguments:args post:YES error:error] != nil);
}

- (unsigned int)eventID
{
	return [[content objectForKey:@"xTimeId"] intValue];
}

- (unsigned int)requestID
{
	return [[content objectForKey:@"xRequest"] intValue];
}

- (NSString *)fullName
{
	return [content objectForKey:@"xPerson"];
}

- (NSString *)eventDescription
{
	return [content objectForKey:@"tDescription"];
}

- (unsigned int)length
{
	return [[content objectForKey:@"iSeconds"] intValue];
}

- (NSDate *)date
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTDate"]];
}

- (NSDate *)dateAdded
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	return [formatter dateFromString:[content objectForKey:@"dtGMTDateAdded"]];
}

@end

@implementation HSTimeEventQuery

- (void)setStartDate:(NSDate *)start
{
	[content setObject:[NSNumber numberWithUnsignedInt:[start timeIntervalSince1970]] forKey:@"start_time"];
}

- (void)setEndDate:(NSDate *)end
{
	[content setObject:[NSNumber numberWithUnsignedInt:[end timeIntervalSince1970]] forKey:@"end_time"];
}

- (void)setUserID:(unsigned int)userID
{
	[content setObject:[NSNumber numberWithUnsignedInt:userID] forKey:@"sUserID"];
}

- (void)setFirstName:(NSString *)name
{
	[content setValue:name forKey:@"sFirstName"];
}

- (void)setLastName:(NSString *)name
{
	[content setValue:name forKey:@"sLastName"];
}

- (void)setEmail:(NSString *)email
{
	[content setValue:email forKey:@"sEmail"];
}

- (void)setMailbox:(unsigned int)mailboxID
{
	[content setObject:[NSNumber numberWithInt:mailboxID] forKey:@"xMailbox"];
}

- (void)setCategoryID:(unsigned int)catID
{
	[content setObject:[NSNumber numberWithInt:catID] forKey:@"xCategory"];
}

- (void)setValue:(NSString *)value forCustomField:(unsigned int)field
{
	[content setValue:value forKey:[NSString stringWithFormat:@"Custom%d", field]];
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

- (void)setOpenedVia:(NSString *)o
{
	[content setObject:o forKey:@"fOpenedVia"];
}

- (void)setAssignedTo:(NSString *)a
{
	[content setObject:a forKey:@"xPersonAssignedTo"];
}

- (void)setOpenedBy:(NSString *)a
{
	[content setObject:a forKey:@"xPersonOpenedBy"];
}

@end
