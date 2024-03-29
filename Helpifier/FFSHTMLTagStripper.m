//
//  FFSHTMLTagStripper.m
//  Helpifier
//
//  Created by Sean Dougall on 12/6/11.
//
//	Copyright (c) 2010-2012 Figure 53 LLC, http://figure53.com
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

#import "FFSHTMLTagStripper.h"

@interface FFSHTMLTagStripper () <NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;

@property (nonatomic, strong) NSDictionary *linkAttributes;

@property (nonatomic, strong) NSMutableArray *substrings;

@end

#pragma mark -

@implementation FFSHTMLTagStripper

@synthesize parser = _parser;

@synthesize linkAttributes = _linkAttributes;

- (NSString *)strippedString
{
    return [[[self.substrings componentsJoinedByString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
}

@synthesize substrings = _substrings;

- (id)initWithHTMLString:(NSString *)string
{
    self = [super init];
    if (self)
    {
        NSString *rootedString = [NSString stringWithFormat:@"<html>%@</html>", string];
        self.substrings = [NSMutableArray array];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[rootedString dataUsingEncoding:rootedString.fastestEncoding]];
        parser.delegate = self;
        self.parser = parser;
        [self.parser parse];
    }
    return self;
}

+ (NSString *)stringByStrippingHTMLFromString:(NSString *)string
{
    FFSHTMLTagStripper *tagStripper = [[FFSHTMLTagStripper alloc] initWithHTMLString:string];
    return tagStripper.strippedString;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.substrings addObject:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    elementName = [elementName lowercaseString];
    
    if ([elementName isEqualToString:@"p"])
        [self.substrings addObject:@"\n\n"];
    else if ([elementName isEqualToString:@"br"])
        [self.substrings addObject:@"\n"];
    else if ([elementName isEqualToString:@"a"])
    {
        [self.substrings addObject:@"["];
        self.linkAttributes = attributeDict;
    }
    else if ([elementName isEqualToString:@"blockquote"])
        [self.substrings addObject:@"<<< "];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    elementName = [elementName lowercaseString];
    
    if ([elementName isEqualToString:@"a"])
        [self.substrings addObject:[NSString stringWithFormat:@"](%@)", [self.linkAttributes objectForKey:@"href"]]];
    else if ([elementName isEqualToString:@"blockquote"])
        [self.substrings addObject:@" >>>"];
}

@end
