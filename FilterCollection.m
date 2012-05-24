//
//  FilterCollection.m
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
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

#import "FilterCollection.h"
#import "HelpifierAppDelegate.h"

@implementation FilterCollection

@synthesize filters = _filters;
@synthesize thisFilterProperties = _thisFilterProperties;

- (NSString *) description
{
    NSMutableString *result = [[@"FilterCollection (" mutableCopy] autorelease];
    BOOL firstFilter = YES;
    for (NSString *filterName in [_filters allKeys])
    {
        [result appendFormat:@"%@%@", (firstFilter ? @"" : @", "), filterName];
        firstFilter = NO;
    }
    return [NSString stringWithFormat:@"%@)", result]; 
}

- (Filter *) filterForID: (NSString *) inID
{
    for (Filter *filter in [_filters allValues])
    {
        if ([[filter.properties objectForKey:@"xFilter"] isEqual:inID])
            return filter;
    }
    return nil;
}

- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qualifiedName 
     attributes: (NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:@"filters"])
    {
        self.filters = [NSMutableDictionary dictionary];
    }
    else if ([elementName isEqualToString:@"filter"])
    {
        self.thisFilterProperties = [NSMutableDictionary dictionary];
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
    if ([elementName isEqualToString:@"filters"])
    {
    }
    else if ([elementName isEqualToString:@"filter"])
    {
        Filter *thisFilter = [[[Filter alloc] initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.filter.get&xFilter=%@", AppDelegate.apiURL, [_thisFilterProperties objectForKey:@"xFilter"]]] autorelease];
        thisFilter.properties = self.thisFilterProperties;
        [self.filters setObject:thisFilter forKey:[self.thisFilterProperties objectForKey:@"xFilter"]];
        self.thisFilterProperties = nil;
    }
    else if ([elementName isEqualToString:@"error"])
    {
        self.errorThrown = YES;
        [self.delegate dataObjectDidFailFetchWithError:self.thisElementString];
    }
    else
    {
        [self.thisFilterProperties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
}

@end
