//
//  Request.m
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "Request.h"
#import "RequestController.h"
#import "RequestViewController.h"
#import "HelpifierAppDelegate.h"
#import "InboxRequestControlsViewController.h"

@implementation Request

- (Request *) initOtherRequestWithRequestID: (NSInteger) reqID
{
    if (self = [super initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.request.get&xRequest=%d", AppDelegate.apiURL, reqID]])
    {
        self.properties = [NSMutableDictionary dictionary];
        self.historyItems = [NSMutableArray array];
        [self.properties setObject:[NSNumber numberWithInteger:reqID] forKey:@"xRequest"];
        [self.properties setObject:[NSNumber numberWithBool:YES] forKey:@"isLoadedAsOtherRequest"];
    }
    return self;
}

@synthesize properties = _properties;
@synthesize historyItems = _historyItems;
@synthesize thisHistoryItemProperties = _thisHistoryItemProperties;
@synthesize lastReplyDate = _lastReplyDate;

- (NSInteger) requestID
{
    return [[_properties objectForKey:@"xRequest"] integerValue];
}

- (NSString *) title
{
    if ([[_properties objectForKey:@"isLoadedAsOtherRequest"] boolValue])
        return [NSString stringWithFormat:@"[%@] %@", [_properties objectForKey:@"xRequest"], [_properties objectForKey:@"sTitle"]];
    return [_properties objectForKey:@"sTitle"];
}

- (NSString *) body
{
    return [_properties objectForKey:@"tBody"];
}

- (NSString *) fullName
{
    return [NSString stringWithFormat:@"%@ %@", [self.properties objectForKey:@"sFirstName"], [self.properties objectForKey:@"sLastName"]];
   return [_properties objectForKey:@"fullName"];
}

- (NSString *) email
{
    return [_properties objectForKey:@"sEmail"];
}

- (BOOL) isUnread
{
    return ([[_properties objectForKey:@"isUnread"] boolValue] || [[_properties objectForKey:@"filterID"] isEqual:@"inbox"]);
}

- (BOOL) urgent
{
    return [[_properties objectForKey:@"fUrgent"] boolValue];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Request #%d (%@ - %@) %@", self.requestID, self.fullName, self.title, self.lastReplyDate];
}

- (NSInteger) numberOfHistoryItems
{
    if (self.isFault) return 0;
    return [self.historyItems count];
}


- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qualifiedName 
     attributes: (NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:@"request_history"])
    {
        self.historyItems = [NSMutableArray array];
    }
    else if ([elementName isEqualToString:@"item"])
    {
        self.thisHistoryItemProperties = [NSMutableDictionary dictionary];
    }
    else if ([elementName isEqualToString:@"reportingTags"])
    {
        [self.properties setObject:[NSMutableArray array] forKey:@"reportingTags"];
    }
    else
    {
        self.thisElementString = [NSMutableString string];
    }
}

- (void) parser: (NSXMLParser *) parser 
  didEndElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI
  qualifiedName: (NSString *) qualifiedName
{
    if ([elementName isEqualToString:@"request_history"] && [self.delegate isKindOfClass:[RequestController class]])
    {
        RequestController *del = (RequestController *)self.delegate;
        if (del.isLoadingOtherRequest)
        {
            del.selection = nil;
            del.requestViewController.selectedRequest = self;
            [del.requestViewController.inboxControls.takeItButton setEnabled:NO];
        }
    }
    else if ([elementName isEqualToString:@"item"])
    {
        HistoryItem *thisItem = [[[HistoryItem alloc] initWithPath:@""] autorelease];
        thisItem.properties = self.thisHistoryItemProperties;
        [self.historyItems addObject:thisItem];
        self.thisHistoryItemProperties = nil;
        
        if (self.lastReplyDate == nil || [thisItem.date compare:self.lastReplyDate] == NSOrderedDescending)
        {
            self.lastReplyDate = thisItem.date;
        }
    }
    else if ([elementName isEqualToString:@"sTitle"] ||
             [elementName isEqualToString:@"sFirstName"] ||
             [elementName isEqualToString:@"sLastName"] ||
             [elementName isEqualToString:@"sEmail"])
    {
        [self.properties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
    else if ([elementName isEqualToString:@"sReportingTag"])
    {
        [[self.properties objectForKey:@"reportingTags"] addObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    else
    {
        [self.thisHistoryItemProperties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
}

@end
