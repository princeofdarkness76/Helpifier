//
//  HistoryItem.m
//  Helpifier
//
//  Created by Sean Dougall on 12/12/10.
//
//	Copyright (c) 2010-2011 Figure 53 LLC, http://figure53.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
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

- (NSString *) bodyPlainText
{
    NSAttributedString *result = [[[NSAttributedString alloc] initWithHTML:[self.body dataUsingEncoding:NSASCIIStringEncoding] documentAttributes:nil] autorelease];
    return [result string];
}

@end
