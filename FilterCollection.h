//
//  FilterCollection.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataHeaders.h"

@class Filter;

@interface FilterCollection : DataObject
{
    NSMutableDictionary *_filters;          // uses xFilter field as key
    NSMutableDictionary *_thisFilterProperties;
}

@property (retain) NSMutableDictionary *filters;
@property (retain) NSMutableDictionary *thisFilterProperties;

- (Filter *) filterForID: (NSString *) inID;

@end
