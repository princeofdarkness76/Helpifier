//
//  HistoryItem.m
//  Helpifier
//
//  Created by Sean Dougall on 12/12/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "HistoryItem.h"


@implementation HistoryItem

@synthesize properties = _properties;

- (NSString *) body
{
    return [self.properties objectForKey:@"tNote"];
}

- (BOOL) public
{
    return [[self.properties objectForKey:@"fPublic"] boolValue];
}

- (NSString *) fullName
{
    return [self.properties objectForKey:@"xPerson"];
}

- (NSDate *) date
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%B %d %Y, %I:%M %p" allowNaturalLanguage:YES] autorelease];
	return [formatter dateFromString:[self.properties objectForKey:@"dtGMTChange"]];
}

- (NSString *) log
{
    return [self.properties objectForKey:@"tLog"];
}

@end
