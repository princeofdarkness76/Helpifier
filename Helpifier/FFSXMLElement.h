//
//  FFSXMLElement.h
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//
//  NOTE: FFSXMLTree/Element are not intended for general-purpose XML
//  parsing. They make a lot of assumptions that won't work everywhere.
//

#import <Foundation/Foundation.h>

@interface FFSXMLElement : NSObject

@property (nonatomic, weak) FFSXMLElement *parent;

@property (nonatomic, strong) NSMutableArray *children;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *stringContent;

@property (readonly) NSString *stringContentAbbreviated;

- (void)addChild:(FFSXMLElement *)child;

// Traversing
- (FFSXMLElement *)firstChildWithName:(NSString *)name;

// Evaluating
- (NSInteger)integerValue;
- (BOOL)boolValue;

- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSDate *)dateForKey:(NSString *)key;
- (NSDate *)dateForKey:(NSString *)key expectingFormat:(NSString *)formatString;

- (NSString *)deepDescriptionWithLevel:(NSUInteger)level;

@end
