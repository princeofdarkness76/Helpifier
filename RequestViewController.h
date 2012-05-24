//
//  RequestViewController.h
//  Helpifier
//
//  Created by Sean Dougall on 9/28/10.
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

- (void) startTakingIt;
- (IBAction) takeIt: (id) sender;
- (IBAction) viewRequest: (id) sender;
- (IBAction) selectOtherRequestTextField: (id) sender;

@end
