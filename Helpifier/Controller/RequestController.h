//
//  RequestController.h
//  Helpifier
//
//  Created by Sean Dougall on 4/17/12.
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
#import <WebKit/WebKit.h>
#import <WebKit/WebResourceLoadDelegate.h>
#import "FHSModel.h"
#import "RequestUpdateNoticeView.h"

@interface RequestController : NSObject <RequestUpdateNoticeViewDelegate>

@property (nonatomic, strong) FHSRequest *request;
@property (strong) IBOutlet NSView *containerView;
@property (strong) IBOutlet NSTextField *subjectField;
@property (strong) IBOutlet NSTextField *numberField;
@property (strong) IBOutlet NSTextField *fromField;
@property (strong) IBOutlet NSProgressIndicator *loadingIndicator;
@property (strong) IBOutlet NSView *bodyContainerView;
@property (strong) IBOutlet WebView *bodyView;
@property (strong) IBOutlet NSView *controlsContainerView;
@property (strong) IBOutlet NSView *controlsViewForRequestsInInbox;
@property (strong) IBOutlet NSView *controlsViewForRequestsWithOwners;
@property (strong) IBOutlet NSView *controlsViewForClosedRequests;
@property (strong) IBOutlet NSView *requestUpdateNoticeView;
@property (strong) IBOutlet NSTextField *requestUpdateFromField;
@property (strong) IBOutlet NSPopUpButton *closeAsPopUp;

- (IBAction)take:(id)sender;
- (IBAction)view:(id)sender;
- (IBAction)closeAs:(id)sender;
- (void)updateRequestViews;
- (void)updateCloseAsPopUpWithStatusTypes:(FHSStatusTypeCollection *)statusTypes;

@end
