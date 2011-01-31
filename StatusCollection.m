//
//  StatusCollection.m
//  Helpifier
//
//  Created by Sean Dougall on 1/31/11.
//  Copyright 2011 Figure 53. All rights reserved.
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
