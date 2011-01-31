//
//  StatusCollection.h
//  Helpifier
//
//  Created by Sean Dougall on 1/31/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataObject.h"


@interface StatusCollection : DataObject 
{
    NSMutableArray          *_statuses;   ///< Each status is an NSDictionary.
    NSMutableDictionary     *_properties;
    NSMutableDictionary     *_thisStatusProperties;
}

+ (StatusCollection *) collection;
- (NSMutableDictionary *) statusWithTitle: (NSString *) title;

@property (retain) NSMutableDictionary *properties;
@property (retain) NSMutableArray *statuses;
@property (retain) NSMutableDictionary *thisStatusProperties;

@end
