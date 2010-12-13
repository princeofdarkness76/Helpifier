//
//  FilterCollection.m
//  HelpifierData
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "FilterCollection.h"

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
        Filter *thisFilter = [[[Filter alloc] initWithPath:[NSString stringWithFormat:@"http://figure53.com/support/api/index.php?method=private.filter.get&xFilter=%@", [_thisFilterProperties objectForKey:@"xFilter"]]] autorelease];
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
