//
//  RequestViewController.h
//  Helpifier
//
//  Created by Sean Dougall on 9/28/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "DataObjectDelegateProtocol.h"

@class RequestController;
@class Request;
@class InboxRequestControlsViewController;
@class EditingRequestControlsViewController;


@interface RequestViewController : NSObject <DataObjectDelegate>
{
	RequestController   *_requestsController;
	Request             *_selectedRequest;
	NSTextField         *_fromTextField;
	NSTextField         *_subjectTextField;
    NSTextField         *_otherRequestTextField;
//	NSTextView          *_bodyTextView;
	WebView             *_bodyHTMLView;
    NSView              *_controlsContainerView;
    NSSplitView         *_splitView;
    InboxRequestControlsViewController      *_inboxControls;
    EditingRequestControlsViewController    *_editingControls;
}

@property (nonatomic, retain) Request *selectedRequest;
@property (assign) IBOutlet RequestController *requestsController;
@property (assign) IBOutlet NSTextField *fromTextField;
@property (assign) IBOutlet NSTextField *subjectTextField;
@property (assign) IBOutlet NSTextField *otherRequestTextField;
//@property (assign) IBOutlet NSTextView *bodyTextView;
@property (assign) IBOutlet WebView *bodyHTMLView;
@property (assign) IBOutlet NSView *controlsContainerView;
@property (assign) IBOutlet NSSplitView *splitView;
@property (readonly) NSString *requestBodyHTML;
@property (readonly) NSAttributedString *requestBody;
@property (assign) InboxRequestControlsViewController *inboxControls;
@property (assign) EditingRequestControlsViewController *editingControls;

- (IBAction) takeIt: (id) sender;
- (IBAction) viewRequest: (id) sender;
- (IBAction) selectOtherRequestTextField: (id) sender;

@end
