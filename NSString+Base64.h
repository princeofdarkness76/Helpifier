//
//  NSString+Base64.h
//  Helpifier
//
//  Created by Sean Dougall on 5/24/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (Base64)

- (NSString *) encodeBase64;

@end


@interface NSString (Base64)

- (NSString *) encodeBase64;

@end
