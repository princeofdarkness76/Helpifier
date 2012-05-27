//
//  HelpSpotController.h
//  Helpifier
//
//  Created by Sean Dougall on 12/4/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSModel.h"

#define FHSFilterDidBeginLoadingNotification @"FHSFilterDidBeginLoadingNotification"
#define FHSFilterDidFinishLoadingNotification @"FHSFilterDidFinishLoadingNotification"
#define FHSRequestHistoryDidBeginLoadingNotification @"FHSRequestHistoryDidBeginLoadingNotification"
#define FHSRequestHistoryDidFinishLoadingNotification @"FHSRequestHistoryDidFinishLoadingNotification"
#define FHSErrorDidChangeNotification @"FHSErrorDidChangeNotification"
#define FHSHistoryDidUpdateNotification @"FHSHistoryDidUpdateNotification"
#define FHSRequestDidDisappearNotification @"FHSRequestDidDisappearNotification"
#define FHSStandaloneRequestDidFinishLoadingNotification @"FHSStandaloneRequestDidFinishLoadingNotification"
#define FHSRequestNotFoundNotification @"FHSRequestNotFoundNotification"
#define FHSStatusTypeCollectionDidFinishLoadingNotification @"FHSStatusTypeCollectionDidFinishLoadingNotification"
#define FHSAuthenticationInformationNeededNotification @"FHSAuthenticationInformationNeededNotification"

@interface HelpSpotController : NSObject

@property (strong) FHSStaff *staff;
@property (strong) FHSFilter *inboxFilter;
@property (strong) FHSFilter *myQueueFilter;
@property (strong) FHSSubscriptionFilter *subscriptionFilter;
@property (strong) FHSStatusTypeCollection *statusTypes;
@property (readonly) NSUInteger totalUnreadCount;
@property (readonly) NSArray *allRequests;
@property (nonatomic, copy) NSString *lastError;

- (void)refresh;
- (void)start;

@end
