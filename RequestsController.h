//
//  RequestsController.h
//  Helpifier
//
//  Created by Sean Dougall on 9/27/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HelpSpot/HelpSpot.h>

@class RequestViewController;

@interface RequestsController : NSObject 
{
	HSRequest              *_selectedRequest;
	NSMutableDictionary    *_inboxRequests;
	NSMutableDictionary    *_myQueueRequests;
	NSMutableDictionary    *_numberOfHistoryItemsByRequestID;
	NSOutlineView          *_requestsOutlineView;
	RequestViewController  *_requestViewController;
	NSTimer                *_refreshTimer;
	NSButton               *_refreshButton;
	NSProgressIndicator    *_refreshProgressIndicator;
	NSInteger               _attentionRequest;
	
	NSError                *_offlineError;
	
	id                      _refreshMutex;
	
	NSString               *_inboxParentItem;
	NSString               *_myQueueParentItem;
}

@property (assign) IBOutlet NSOutlineView *requestsOutlineView;
@property (assign) IBOutlet RequestViewController *requestViewController;
@property (assign) IBOutlet NSButton *refreshButton;
@property (assign) IBOutlet NSProgressIndicator *refreshProgressIndicator;
@property (retain) HSRequest *selection;
@property (retain) NSError *offlineError;

- (IBAction) refreshRequests: (id) sender;

@end
