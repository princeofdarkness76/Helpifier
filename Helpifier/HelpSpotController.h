//
//  HelpSpotController.h
//  Helpifier
//
//  Created by Sean Dougall on 12/4/11.
//
//	Copyright (c) 2010-2012 Figure 53 LLC, http://figure53.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
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
