//
//  FFSHTMLTagStripper.h
//  Helpifier
//
//  Created by Sean Dougall on 12/6/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFSHTMLTagStripper : NSObject

@property (readonly) NSString *strippedString;

- (id)initWithHTMLString:(NSString *)string;

// One-liner convenience method
+ (NSString *)stringByStrippingHTMLFromString:(NSString *)string;

@end
