//
//  FHSFilter.h
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FHSObject.h"

@interface FHSFilter : FHSObject <FHSObjectDelegate>

@property (nonatomic, copy) NSString *filterID;
@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, strong) NSMutableDictionary *requests;
@property (readonly) NSDictionary *expiredRequests;
@property (readonly) NSDictionary *expiredRequestIndexes;
@property (readonly) NSArray *sortedRequestIDs;
@property (readonly) NSUInteger unreadCount;
@property (readonly) BOOL isInbox;
@property (readonly) BOOL fetchInProgress;
@property (assign) BOOL shouldCheckFilterStream;

@end
