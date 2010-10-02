#import "HSItem.h"

@implementation HSItem

- (id)init
{
	self = [super init];
	
	content = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (id)initWithContent:(NSDictionary *)c
{
	self = [self init];
	
	[content addEntriesFromDictionary:c];
	
	return self;
}

- (void)dealloc
{
	[content release];
	[super dealloc];
}

- (NSString *)description
{
	return [content description];
}

- (NSDictionary *)_content
{
	return content;
}

- (NSMutableDictionary *) content
{
    return content;
}

@end
