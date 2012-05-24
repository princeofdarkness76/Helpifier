//
//  RequestController.h
//  Helpifier
//
//  Created by Sean Dougall on 4/17/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
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
