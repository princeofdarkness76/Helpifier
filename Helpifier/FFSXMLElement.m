//
//  FFSXMLElement.m
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
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
