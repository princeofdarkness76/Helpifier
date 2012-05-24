//
//  NSDictionary+HTTPBodySerialization.m
//  Helpifier
//
//  Created by Sean Dougall on 5/23/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
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
