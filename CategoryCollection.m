//
//  CategoryCollection.m
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

#import "CategoryCollection.h"
#import "HelpifierAppDelegate.h"


static CategoryCollection *_sharedCollection = nil;

@implementation CategoryCollection

+ (CategoryCollection *) collection
{
    if (_sharedCollection == nil)
    {
        _sharedCollection = [[CategoryCollection alloc] initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.request.getCategories", AppDelegate.apiURL]];
        _sharedCollection.categories = nil;
        _sharedCollection.thisCategoryProperties = nil;
        _sharedCollection.thisTagProperties = nil;
        _sharedCollection.properties = [NSMutableDictionary dictionary];
        [_sharedCollection beginFetch];
    }
    return _sharedCollection;
}

- (void) dealloc
{
    self.categories = nil;
    self.properties = nil;
    self.thisCategoryProperties = nil;
    self.thisTagProperties = nil;
    
    [super dealloc];
}



@synthesize properties = _properties;
@synthesize categories = _categories;
@synthesize thisCategoryProperties = _thisCategoryProperties;
@synthesize thisTagProperties = _thisTagProperties;

- (NSMutableDictionary *) categoryWithTitle: (NSString *) title
{
    for (NSMutableDictionary *cat in self.categories)
        if ([[cat objectForKey:@"sCategory"] isEqual:title])
            return cat;
    return nil;
}

- (NSMutableDictionary *) tagWithTitle: (NSString *) tagTitle inCategoryWithTitle: (NSString *) categoryTitle
{
    NSArray *tags = [[self categoryWithTitle:categoryTitle] objectForKey:@"reportingTags"];
    for (NSMutableDictionary *tag in tags)
    {
        if ([[tag objectForKey:@"sReportingTag"] isEqual:tagTitle])
            return tag;
    }
    return nil;
}


- (void) parser: (NSXMLParser *) parser 
didStartElement: (NSString *) elementName 
   namespaceURI: (NSString *) namespaceURI 
  qualifiedName: (NSString *) qualifiedName 
     attributes: (NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:@"categories"])
    {
        self.categories = [NSMutableArray array];
    }
    else if ([elementName isEqualToString:@"category"])
    {
        self.thisCategoryProperties = [NSMutableDictionary dictionary];
    }
    else if ([elementName isEqualToString:@"reportingTags"])
    {
        [self.thisCategoryProperties setObject:[NSMutableArray array] forKey:@"reportingTags"];
    }
    else if ([elementName isEqualToString:@"tag"])
    {
        self.thisTagProperties = [NSMutableDictionary dictionary];
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
    if ([elementName isEqualToString:@"categories"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoriesDidChangeNotification" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"categories", nil]];
    }
    else if ([elementName isEqualToString:@"category"])
    {
        [self.categories addObject:[[self.thisCategoryProperties copy] autorelease]];
    }
    else if ([elementName isEqualToString:@"xCategory"] ||
             [elementName isEqualToString:@"sCategory"])
    {
        [self.thisCategoryProperties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
    else if ([elementName isEqualToString:@"reportingTags"])
    {
        // Do nothing
    }
    else if ([elementName isEqualToString:@"tag"])
    {
        [[self.thisCategoryProperties objectForKey:@"reportingTags"] addObject:self.thisTagProperties];
    }
    else if ([elementName isEqualToString:@"xReportingTag"] ||
             [elementName isEqualToString:@"sReportingTag"])
    {
        [self.thisTagProperties setObject:[self.thisElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }
}

@end
