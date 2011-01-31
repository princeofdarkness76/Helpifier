//
//  Staff.m
//  Helpifier
//
//  Created by Sean Dougall on 1/31/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import "Staff.h"
#import "HelpifierAppDelegate.h"


static Staff *_sharedStaff = nil;

@implementation Staff

+ (Staff *) staff
{
    if (_sharedStaff == nil)
    {
        _sharedStaff = [[Staff alloc] initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.util.getActiveStaff", AppDelegate.apiURL]];
        _sharedStaff.people = nil;
        _sharedStaff.thisPersonProperties = nil;
        _sharedStaff.properties = [NSMutableDictionary dictionary];
        [_sharedStaff beginFetch];
    }
    return _sharedStaff;
}

- (void) dealloc
{
    self.people = nil;
    self.properties = nil;
    self.thisPersonProperties = nil;
    
    [super dealloc];
}

- (NSMutableDictionary *) personWithEmail: (NSString *) email
{
    for (NSMutableDictionary *person in self.people)
        if ([[person objectForKey:@"sEmail"] isEqualToString:email])
            return person;
    return nil;
}


@synthesize properties = _properties;
@synthesize people = _people;
@synthesize thisPersonProperties = _thisPersonProperties;

- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qualifiedName 
     attributes: (NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:@"staff"])
    {
        self.people = [NSMutableArray array];
    }
    else if ([elementName isEqualToString:@"person"])
    {
        self.thisPersonProperties = [NSMutableDictionary dictionary];
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
    if ([elementName isEqualToString:@"staff"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StaffDidChangeNotification" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"staff", nil]];
    }
    else if ([elementName isEqualToString:@"person"])
    {
        [self.people addObject:[[self.thisPersonProperties copy] autorelease]];
    }
    else if ([elementName isEqualToString:@"fullname"] ||
             [elementName isEqualToString:@"sFName"] ||
             [elementName isEqualToString:@"sLName"] ||
             [elementName isEqualToString:@"sEmail"] ||
             [elementName isEqualToString:@"xPerson"])
    {
        [self.thisPersonProperties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
}

@end
