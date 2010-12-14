//
//  Request.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataHeaders.h"

@interface Request : DataObject
{
    NSMutableDictionary     *_properties;
    NSMutableArray          *_historyItems;
    NSMutableDictionary     *_thisHistoryItemProperties;
    NSInteger                _numberOfHistoryItemsOnLastRefresh;
    NSDate                  *_lastReplyDate;
}

@property (retain) NSMutableDictionary *properties;
@property (retain) NSMutableArray *historyItems;
@property (retain) NSMutableDictionary *thisHistoryItemProperties;

@property (readonly) NSInteger requestID;
@property (readonly) NSString *title;
@property (readonly) NSString *body;
@property (readonly) NSString *fullName;
@property (readonly) NSString *email;
@property (readonly) BOOL isUnread;
@property (readonly) BOOL urgent;
@property (retain) NSDate *lastReplyDate;

@end
