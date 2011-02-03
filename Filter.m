//
//  Filter.m
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "Filter.h"
#import "HelpifierAppDelegate.h"

@implementation Filter

@synthesize properties = _properties;
@synthesize requests = _requests;
@synthesize thisRequestProperties = _thisRequestProperties;

- (NSArray *) sortedRequests
{
    NSMutableArray *reqs = [NSMutableArray arrayWithArray:[self.requests allValues]];
    [reqs sortUsingDescriptors:[NSArray arrayWithObjects:
                                [NSSortDescriptor sortDescriptorWithKey:@"urgent" ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"lastReplyDate" ascending:NO],
                                nil]];
    return reqs;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Filter %@", [self.properties objectForKey:@"xFilter"]];
}

- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qualifiedName 
     attributes: (NSDictionary *) attributeDict
{
   if ([elementName isEqualToString:@"filter"])
    {
        self.requests = [NSMutableDictionary dictionary];
    }
    else if ([elementName isEqualToString:@"request"])
    {
        self.thisRequestProperties = [NSMutableDictionary dictionary];
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
    if ([elementName isEqualToString:@"filter"])
    {
    }
    else if ([elementName isEqualToString:@"request"])
    {
        Request *thisRequest = [[[Request alloc] initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.request.get&xRequest=%@", AppDelegate.apiURL, [_thisRequestProperties objectForKey:@"xRequest"]]] autorelease];
        thisRequest.properties = self.thisRequestProperties;
        if ([_thisRequestProperties objectForKey:@"xRequest"] != nil)
            [self.requests setObject:thisRequest forKey:[self.thisRequestProperties objectForKey:@"xRequest"]];
        self.thisRequestProperties = nil;
    }
    else
    {
        [self.thisRequestProperties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
}


@end
