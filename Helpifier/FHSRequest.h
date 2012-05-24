//
//  FHSRequest.h
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FHSObject.h"

@class FHSFilter;

@interface FHSRequest : FHSObject

@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *previewNote;
@property (nonatomic) BOOL unread;
@property (nonatomic) BOOL urgent;
@property (nonatomic, weak) FHSFilter *filter;
@property (copy) NSArray *historyItems;
@property (nonatomic) BOOL justAdded;
@property (nonatomic) BOOL skeleton;    ///< Flag to indicate that this is a newly fetched request from a subscription, in which case it will have extremely incomplete information.
@property (nonatomic) BOOL standalone;
@property (assign) BOOL open;
@property (assign) BOOL notFound;
@property (readonly) NSInteger mostRecentHistoryItemID;

- (id)initWithXMLElement:(FFSXMLElement *)element delegate:(id<FHSObjectDelegate>)delegate;
- (id)initWithRequestID:(NSInteger)requestID delegate:(id<FHSObjectDelegate>)delegate;
- (void)updateWithRequest:(FHSRequest *)otherRequest;
- (void)viewOnWeb;
- (void)takeOnWeb;
- (void)closeWithStatus:(NSInteger)status;

@end
