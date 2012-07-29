//
//  NSDictionary+HTTPBodySerialization.m
//  Helpifier
//
//  Created by Sean Dougall on 5/23/12.
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

#import "NSDictionary+HTTPBodySerialization.h"

@interface NSString (HTTPBodySerialization)

- (NSString *)httpBodyEncodedString;

@end

#pragma mark -

@implementation NSString (HTTPBodySerialization)

- (NSString *)httpBodyEncodedString
{
    return self;
}

@end

@implementation NSDictionary (HTTPBodySerialization)

- (NSData *)httpBodyData
{
    NSMutableArray *components = [NSMutableArray array];
    for ( NSString *key in [self allKeys] )
    {
        [components addObject:[NSString stringWithFormat:@"%@=%@", [key httpBodyEncodedString], [[self objectForKey:key] httpBodyEncodedString]]];
    }
    NSString *body = [components componentsJoinedByString:@"&"];
    return [NSData dataWithBytes:[body UTF8String] length:[body length]];
}

@end
