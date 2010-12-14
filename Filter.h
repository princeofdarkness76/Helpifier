//
//  Filter.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataHeaders.h"

@interface Filter : DataObject
{
    NSMutableDictionary     *_requests;          // uses xRequest field as key
    NSMutableDictionary     *_thisRequestProperties;
    NSMutableDictionary     *_properties;
}

@property (retain) NSMutableDictionary *properties;
@property (retain) NSMutableDictionary *requests;
@property (readonly) NSArray *sortedRequests;
@property (retain) NSMutableDictionary *thisRequestProperties;

@end
