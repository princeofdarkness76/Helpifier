//
//  FFSHTMLTagStripper.m
//  Helpifier
//
//  Created by Sean Dougall on 12/6/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
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
