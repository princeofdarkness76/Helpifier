//
//  Staff.m
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
