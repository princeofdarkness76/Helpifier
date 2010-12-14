//
//  RequestController.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataHeaders.h"

@class RequestViewController;

@interface RequestController : NSObject <DataObjectDelegate>
{
    FilterCollection        *_filters;
    id                       _refreshMutex;
    NSTimer                 *_refreshTimer;
    NSMutableArray          *_enabledFilterNames;
    NSMutableArray          *_requestsWithPendingFetches;

    NSString                *_offlineError;
    BOOL                     _hasLoadedOutlineView;
    NSInteger                _selectedRequestID;
    
    NSOutlineView           *_requestsOutlineView;
    NSButton                *_refreshButton;
    NSProgressIndicator     *_refreshProgressIndicator;
    BOOL                     _isRefreshingByUserCommand;
    RequestViewController   *_requestViewController;
}

@property (retain) FilterCollection *filters;
@property (retain) NSMutableArray *enabledFilterNames;
@property (retain) NSString *offlineError;
@property (assign) Request *selection;

@property (assign) IBOutlet NSOutlineView *requestsOutlineView;
@property (assign) IBOutlet NSButton *refreshButton;
@property (assign) IBOutlet NSProgressIndicator *refreshProgressIndicator;
@property (assign) IBOutlet RequestViewController *requestViewController;

- (IBAction) refreshRequests: (id) sender;

- (Request *) requestForID: (id) inID;

@end
