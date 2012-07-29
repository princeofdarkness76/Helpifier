//
//  FHSHistoryItem.m
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//
//	Copyright (c) 2010-2012 Figure 53 LLC, http://figure53.com
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

#import "FHSHistoryItem.h"
#import "FFSHTMLTagStripper.h"

@interface FHSHistoryItem ()

@property (nonatomic) BOOL isHTML;

@end

#pragma mark -

@implementation FHSHistoryItem

@synthesize request = _request;

@synthesize historyID = _historyID;

@synthesize requestID = _requestID;

@synthesize person = _person;

@synthesize note = _note;

@synthesize log = _log;

@synthesize date = _date;

@synthesize isHTML = _isHTML;

- (NSString *)plainTextNote
{
    if (self.isHTML)
        return [FFSHTMLTagStripper stringByStrippingHTMLFromString:self.note];
    return self.note;
}

- (NSString *)noteWithDetails
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    return [NSString stringWithFormat:@"<div class=\"item%@%@\"><p class=\"name\">%@%@</p><p class=\"date\">%@</p>%@</div>", 
     [self.log isEqual:@""] ? @" requestitem" : @" logitem",
     (!self.public && self.note != nil) ? @" private" : @"",
     self.person, 
     (!self.public && self.note != nil) ? @" (private)" : @"",
     [dateFormatter stringFromDate:self.date],
     self.note == nil ? self.log : self.note];
}

@synthesize public = _public;

- (id)initWithXMLElement:(FFSXMLElement *)element
{
    self = [super init];
    if (self)
    {
        self.historyID = [element stringForKey:@"xRequestHistory"];
        self.requestID = [element stringForKey:@"xRequest"];
        self.person = [element stringForKey:@"xPerson"];
        self.note = [element stringForKey:@"tNote"];
        self.log = [element stringForKey:@"tLog"];
        self.date = [element dateForKey:@"dtGMTChange"];
        self.public = [element boolForKey:@"fPublic"];
        self.isHTML = [element boolForKey:@"fNoteIsHTML"];
    }
    return self;
}

@end
