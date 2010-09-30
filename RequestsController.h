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
	NSMutableDictionary    *_inboxRequests;
	NSMutableDictionary    *_myQueueRequests;
	NSMutableDictionary    *_numberOfHistoryItemsByRequestID;
	NSOutlineView          *_requestsOutlineView;
	RequestViewController  *_requestViewController;
	NSTimer                *_refreshTimer;
	NSButton               *_refreshButton;
	NSProgressIndicator    *_refreshProgressIndicator;
	NSInteger               _attentionRequest;
	
	id                      _refreshMutex;
	
	NSString               *_inboxParentItem;
	NSString               *_myQueueParentItem;
}

@property (assign) IBOutlet NSOutlineView *requestsOutlineView;
@property (assign) IBOutlet RequestViewController *requestViewController;
@property (assign) IBOutlet NSButton *refreshButton;
@property (assign) IBOutlet NSProgressIndicator *refreshProgressIndicator;
@property (assign) id selection;

- (IBAction) refreshRequests: (id) sender;

@end
