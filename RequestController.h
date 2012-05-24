//
//  RequestController.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//
//	Copyright (c) 2010-2011 Figure 53 LLC, http://figure53.com
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

#import <Cocoa/Cocoa.h>
#import "DataHeaders.h"

@class RequestViewController;

@interface RequestController : NSObject <DataObjectDelegate, NSSplitViewDelegate>
{
    FilterCollection        *_filters;
    SubscriptionFilter      *_subscriptions;
    id                       _refreshMutex;
    NSTimer                 *_refreshTimer;
    NSMutableArray          *_enabledFilterNames;
    NSMutableArray          *_requestsWithPendingFetches;

    NSString                *_offlineError;
    BOOL                     _hasLoadedOutlineView;
    NSInteger                _selectedRequestID;
    
	IBOutlet NSSplitView	*_requestSplitView;
    NSOutlineView           *_requestsOutlineView;
    NSButton                *_refreshButton;
    NSProgressIndicator     *_refreshProgressIndicator;
    BOOL                     _isRefreshingByUserCommand;
    BOOL                     _isLoadingOtherRequest;
    RequestViewController   *_requestViewController;
}

@property (retain) FilterCollection *filters;
@property (retain) SubscriptionFilter *subscriptions;
@property (retain) NSMutableArray *enabledFilterNames;
@property (retain) NSString *offlineError;
@property (assign) Request *selection;
@property (assign) BOOL isLoadingOtherRequest;

@property (assign) IBOutlet NSOutlineView *requestsOutlineView;
@property (assign) IBOutlet NSButton *refreshButton;
@property (assign) IBOutlet NSProgressIndicator *refreshProgressIndicator;
@property (assign) IBOutlet RequestViewController *requestViewController;

- (IBAction) refreshRequests: (id) sender;
- (IBAction) selectOtherRequest: (id) sender;

- (Request *) requestForID: (id) inID;

- (void) pendingFetchesDidFinish;

@end
