//
//  FFSXMLTree.h
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//
//  NOTE: FFSXMLTree/Element are not intended for general-purpose XML
//  parsing. They make a lot of assumptions that won't work everywhere.
//

#import <Foundation/Foundation.h>

@class FFSXMLElement;
@class FFSXMLTree;

@protocol FFSXMLTreeDelegate <NSObject>

- (void)treeDidFinishParsing:(FFSXMLTree *)tree;

@end

#pragma mark -

@interface FFSXMLTree : NSObject

@property (nonatomic, weak) id <FFSXMLTreeDelegate> delegate;

@property (readonly) FFSXMLElement *rootElement;

- (id)initWithData:(NSData *)data delegate:(id <FFSXMLTreeDelegate>)delegate;

- (NSString *)deepDescription;

@end
