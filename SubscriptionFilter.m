//
//  SubscriptionFilter.m
//  Helpifier
//
//  Created by Sean Dougall on 7/6/10.
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

#import "SubscriptionFilter.h"
#import "DataHeaders.h"
#import "HelpifierAppDelegate.h"

@implementation SubscriptionFilter

- (NSString *) description
{
    return [NSString stringWithFormat:@"Subscription pseudo-filter"];
}

- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qualifiedName 
     attributes: (NSDictionary *) attributeDict
{
   if ([elementName isEqualToString:@"subscriptions"])
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
    if ([elementName isEqualToString:@"subscriptions"])
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
