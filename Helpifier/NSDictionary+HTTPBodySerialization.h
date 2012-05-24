//
//  NSDictionary+HTTPBodySerialization.h
//  Helpifier
//
//  Created by Sean Dougall on 5/23/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HTTPBodySerialization)

- (NSData *)httpBodyData;

@end
