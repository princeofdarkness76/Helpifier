//
//  StatusCollection.m
//  Helpifier
//
//  Created by Sean Dougall on 1/31/11.
//
//	Copyright (c) 2011 Figure 53 LLC, http://figure53.com
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

#import "StatusCollection.h"
#import "HelpifierAppDelegate.h"


static StatusCollection *_sharedCollection = nil;

@implementation StatusCollection

+ (StatusCollection *) collection
{
    if (_sharedCollection == nil)
    {
        _sharedCollection = [[StatusCollection alloc] initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.request.getStatusTypes", AppDelegate.apiURL]];
        _sharedCollection.statuses = nil;
        _sharedCollection.thisStatusProperties = nil;
        _sharedCollection.properties = [NSMutableDictionary dictionary];
        [_sharedCollection beginFetch];
    }
    return _sharedCollection;
}

- (void) dealloc
{
    self.statuses = nil;
    self.properties = nil;
    self.thisStatusProperties = nil;
    
    [super dealloc];
}



@synthesize properties = _properties;
@synthesize statuses = _statuses;
@synthesize thisStatusProperties = _thisStatusProperties;

- (NSMutableDictionary *) statusWithTitle: (NSString *) title
{
    for (NSMutableDictionary *status in self.statuses)
        if ([[status objectForKey:@"sStatus"] isEqual:title])
            return status;
    return nil;
}


- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qualifiedName 
     attributes: (NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:@"results"])
    {
        self.statuses = [NSMutableArray array];
    }
    else if ([elementName isEqualToString:@"status"])
    {
        self.thisStatusProperties = [NSMutableDictionary dictionary];
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
    if ([elementName isEqualToString:@"results"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusesDidChangeNotification" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"statuses", nil]];
    }
    else if ([elementName isEqualToString:@"status"])
    {
        [self.statuses addObject:[[self.thisStatusProperties copy] autorelease]];
    }
    else if ([elementName isEqualToString:@"xStatus"] ||
             [elementName isEqualToString:@"sStatus"])
    {
        [self.thisStatusProperties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
}

@end
