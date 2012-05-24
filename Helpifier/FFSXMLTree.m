//
//  FFSXMLTree.m
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//
//  NOTE: FFSXMLTree/Element are not intended for general-purpose XML
//  parsing. They make a lot of assumptions that won't work everywhere.
//

#import "FFSXMLTree.h"
#import "FFSXMLElement.h"

@interface FFSXMLTree () <NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;

@property (nonatomic, strong) NSMutableArray *elementStack;

@property (nonatomic, strong) NSMutableString *elementContent;

@end

#pragma mark -

@implementation FFSXMLTree

- (FFSXMLElement *)rootElement
{
    if ([self.elementStack count] > 0)
        return [self.elementStack objectAtIndex:0];

    return nil;
}

@synthesize delegate = _delegate;

@synthesize parser = _parser;

@synthesize elementContent = _elementContent;

@synthesize elementStack = _elementStack;

- (id)initWithData:(NSData *)data delegate:(id <FFSXMLTreeDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.elementStack = [NSMutableArray array];
        self.parser = [[NSXMLParser alloc] initWithData:data];
        self.parser.delegate = self;
        
        // The actual parsing must be done in the background, or we won't be able to return until after the delegate has been notified.
        __block FFSXMLTree *tree = self;
        dispatch_queue_t parseQueue = dispatch_queue_create("FFSXMLParse", NULL);
        dispatch_async(parseQueue, ^(void){
            [tree.parser parse];
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                [tree.delegate treeDidFinishParsing:tree];
            });
        });
        dispatch_release(parseQueue);
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    FFSXMLElement *element = [[FFSXMLElement alloc] init];
    element.name = elementName;
    [(FFSXMLElement *)[self.elementStack lastObject] addChild:element];
    [self.elementStack addObject:element];
    self.elementContent = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    FFSXMLElement *element = [self.elementStack lastObject];
    element.stringContent = self.elementContent;
    self.elementContent = nil;
    
    if ([self.elementStack count] > 1)
        [self.elementStack removeLastObject];   // Pop the element stack, but leave the root element in place for querying later.
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.elementContent appendString:string];
}

- (NSString *)deepDescription
{
    return [NSString stringWithFormat:@"FFSXMLTree:\n%@", [self.rootElement deepDescriptionWithLevel:0]];
}

@end
