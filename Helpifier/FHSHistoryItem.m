//
//  FHSHistoryItem.m
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
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
