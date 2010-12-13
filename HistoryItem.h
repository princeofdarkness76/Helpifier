//
//  HistoryItem.h
//  Helpifier
//
//  Created by Sean Dougall on 12/12/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataHeaders.h"

@interface HistoryItem : DataObject 
{
    NSMutableDictionary     *_properties;

}

@property (retain) NSMutableDictionary *properties;
@property (readonly) NSString *body;
@property (readonly) BOOL public;
@property (readonly) NSString *fullName;
@property (readonly) NSDate *date;
@property (readonly) NSString *log;


@end
