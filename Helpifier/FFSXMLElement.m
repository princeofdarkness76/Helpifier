//
//  FFSXMLElement.m
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//
//  NOTE: FFSXMLTree/Element are not intended for general-purpose XML
//  parsing. They make a lot of assumptions that won't work everywhere.
//

#import "FFSXMLElement.h"

@implementation FFSXMLElement

@synthesize parent = _parent;

@synthesize children = _children;

@synthesize name = _name;

@synthesize stringContent = _stringContent;

- (void)addChild:(FFSXMLElement *)child
{
    if (!self.children)
        self.children = [NSMutableArray array];
    
    [self.children addObject:child];
}

- (NSString *)stringContentAbbreviated
{
    if (!self.stringContent) return @"";
    NSScanner *s = [NSScanner scannerWithString:self.stringContent];
    NSString *firstLine;
    if ([s scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&firstLine])
    {
        return firstLine.length > 20 ? [[firstLine substringToIndex:19] stringByAppendingString:@"..."] : firstLine;
    }
    return @"";
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"FFSXMLElement (%@) %@ (%lu child%@)", self.name, self.stringContent, [self.children count], [self.children count] == 1 ? @"" : @"ren"];
}

#pragma mark - Traversing

- (FFSXMLElement *)firstChildWithName:(NSString *)name
{
    for (FFSXMLElement *child in self.children)
    {
        if ([child.name isEqualToString:name])
            return child;
    }
    return nil;
}

#pragma mark - Evaluating

- (NSInteger)integerValue
{
    return [self.stringContent integerValue];
}

- (BOOL)boolValue
{
    return [self.stringContent boolValue];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [self firstChildWithName:key].stringContent;
}

- (NSInteger)integerForKey:(NSString *)key
{
    return [[self firstChildWithName:key] integerValue];
}

- (BOOL)boolForKey:(NSString *)key
{
    id child = [self firstChildWithName:key];
    if ([child isEqual:@"false"])
        return NO;
    return [child boolValue];
}

- (NSDate *)dateForKey:(NSString *)key
{
    return [self dateForKey:key expectingFormat:@"MMM dd yyyy, hh:mm a"];
}

- (NSDate *)dateForKey:(NSString *)key expectingFormat:(NSString *)formatString
{
    NSString *dateString = [self firstChildWithName:key].stringContent;
    if (!dateString)
        return nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    [dateFormatter setLenient:YES];
    return [dateFormatter dateFromString:dateString];
}

- (NSString *)deepDescriptionWithLevel:(NSUInteger)level
{
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@: %@", self.name, self.stringContentAbbreviated];
    for (FFSXMLElement *child in self.children)
    {
        [result appendString:@"\n  "];
        for (int i = 0; i < level; i++)
            [result appendString:@"  "];
        [result appendString:[child deepDescriptionWithLevel:level + 1]];
    }
    return [result copy];
}

@end
