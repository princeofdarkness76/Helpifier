//
//  RequestController.m
//  Helpifier
//
//  Created by Sean Dougall on 4/17/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "RequestController.h"
#import "HelpSpotController.h"
#import "HelpifierAppDelegate.h"

@interface RequestController ()

@property (assign) NSInteger mostRecentHistoryItemID;

- (void)_requestDidFinishLoading:(FHSRequest *)request;
- (void)_requestDidFinishAutoreloading:(FHSRequest *)request;
- (void)_showUpdateNotice;
- (void)_reloadHistoryView;

@end

#pragma mark - 

@implementation RequestController

@synthesize request = _request;

@synthesize containerView = _containerView;

@synthesize subjectField = _subjectField;

@synthesize numberField = _numberField;

@synthesize fromField = _fromField;

@synthesize loadingIndicator = _loadingIndicator;

@synthesize bodyContainerView = _bodyContainerView;

@synthesize bodyView = _bodyView;

@synthesize controlsContainerView = _controlsContainerView;

@synthesize controlsViewForRequestsInInbox = _controlsViewForRequestsInInbox;

@synthesize controlsViewForRequestsWithOwners = _controlsViewForRequestsWithOwners;

@synthesize controlsViewForClosedRequests = _controlsViewForClosedRequests;

@synthesize requestUpdateNoticeView = _requestUpdateNoticeView;

@synthesize requestUpdateFromField = _requestUpdateFromField;

@synthesize closeAsPopUp = _closeAsPopUp;

@synthesize mostRecentHistoryItemID = _mostRecentHistoryItemID;

- (void)setRequest:(FHSRequest *)request
{
    _request = request;
    if ( _request )
    {
        _subjectField.stringValue = request.title;
        _numberField.stringValue = request.requestID;
        _fromField.stringValue = request.customerName;
        [_containerView.animator setHidden:NO];
        [_bodyContainerView.animator setHidden:YES];
        [_loadingIndicator.animator setHidden:NO];
        [_loadingIndicator startAnimation:self];
        
        __block RequestController *controller = self;
        _request.completionHandler = ^(FHSObject *sender){
            if ( controller.request == sender )
            {
                [controller _requestDidFinishLoading:(FHSRequest *)sender];
            }
        };
        [_request fetch];
    }
    else
    {
        [_containerView.animator setHidden:YES];
    }
}

- (void)awakeFromNib
{
    if ( _request )
    {
        _subjectField.stringValue = _request.title;
        _numberField.stringValue = _request.requestID;
        _fromField.stringValue = _request.customerName;
    }
    
    [_containerView setHidden:NO];
    [_bodyContainerView setHidden:YES];
    [_loadingIndicator setHidden:NO];
    [_loadingIndicator startAnimation:self];
}

- (IBAction)take:(id)sender
{
    [_request takeOnWeb];
}

- (IBAction)view:(id)sender
{
    [_request viewOnWeb];
}

- (IBAction)closeAs:(id)sender
{
    [_request closeWithStatus:[sender tag]];
    
    [self _requestDidFinishLoading:_request];
}

- (void)updateRequestViews
{
    _subjectField.stringValue = _request.title ? _request.title : @"";
    _numberField.stringValue = _request.requestID ? _request.requestID : @"";
    _fromField.stringValue = _request.customerName ? _request.customerName : @"";
}

- (void)updateCloseAsPopUpWithStatusTypes:(FHSStatusTypeCollection *)statusTypes
{
    [self.closeAsPopUp removeAllItems];
    [self.closeAsPopUp addItemWithTitle:@"Close As…"];
    for ( NSNumber *key in [[statusTypes.statuses allKeys] sortedArrayUsingSelector:@selector(compare:)] )
    {
        NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:[statusTypes.statuses objectForKey:key] action:@selector(closeAs:) keyEquivalent:@""];
        [newItem setTag:[key integerValue]];
        [newItem setTarget:self];
        [self.closeAsPopUp.menu addItem:newItem];
    }
}

- (void)_requestDidFinishLoading:(FHSRequest *)request
{
    if ( request.notFound ) return;  ///< If the request doesn't exist, we don't have to do anything; we'll be replaced by a nil request being pushed.
    
    [[NSAnimationContext currentContext] setDuration:0.3];
    [_bodyContainerView setAlphaValue:0.0];
    [_bodyContainerView setHidden:NO];
    [_loadingIndicator stopAnimation:self];
    [_loadingIndicator setHidden:YES];
    [_bodyContainerView.animator setAlphaValue:1.0];
    [self updateCloseAsPopUpWithStatusTypes:[(HelpifierAppDelegate *)[NSApp delegate] statusTypes]];
    
    // Figure out which controls view to put in, based on the status and location of the request.
    NSView *controlsView;
    if ( _request.filter.isInbox )
        controlsView = _controlsViewForRequestsInInbox;
    else if ( _request.open )
        controlsView = _controlsViewForRequestsWithOwners;
    else
        controlsView = _controlsViewForClosedRequests;
    
    __block NSArray *oldSubviews = [_controlsContainerView.subviews copy];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        for ( NSView *oldSubview in oldSubviews )
            [oldSubview removeFromSuperview];
    }];
    [NSAnimationContext beginGrouping];
    for ( NSView *oldSubview in oldSubviews )
    {
        [oldSubview.animator setAlphaValue:0.0];
    }
    [NSAnimationContext endGrouping];
    
    [_controlsContainerView addSubview:controlsView];
    controlsView.alphaValue = 0.0;
    controlsView.frame = _controlsContainerView.bounds;
    NSPoint origin = _controlsContainerView.bounds.origin;
    origin.y -= _controlsContainerView.bounds.size.height;
    [controlsView setFrameOrigin:origin];
    [controlsView.animator setAlphaValue:1.0];
    [controlsView.animator setFrameOrigin:_controlsContainerView.bounds.origin];
    
    [self _reloadHistoryView];
    
    __block RequestController *controller = self;
    _request.completionHandler = ^(FHSObject *sender){
        [controller _requestDidFinishAutoreloading:(FHSRequest *)sender];
    };
    [_request fetchAfterAppropriateDelay];
}

- (void)_requestDidFinishAutoreloading:(FHSRequest *)request
{
    if ( _mostRecentHistoryItemID < request.mostRecentHistoryItemID )
    {
        self.mostRecentHistoryItemID = request.mostRecentHistoryItemID;
        [self _showUpdateNotice];
    }
    
    __block RequestController *controller = self;
    _request.completionHandler = ^(FHSObject *sender){
        [controller _requestDidFinishAutoreloading:(FHSRequest *)sender];
    };
    
    // Schedule next load only if we're the active request controller (testable by whether or not our container view is on screen)
    if ( self.containerView.superview )
    {
        [_request fetchAfterAppropriateDelay];
    }
}

- (void)_showUpdateNotice
{
    NSRect bodyFrame = NSMakeRect( 0, 39, _containerView.frame.size.width, _containerView.frame.size.height - 113 );
    if ( !_requestUpdateNoticeView.superview )
    {
        [_containerView addSubview:_requestUpdateNoticeView];
        _requestUpdateNoticeView.alphaValue = 0.0;
        _requestUpdateNoticeView.frame = NSMakeRect(0, _containerView.frame.size.height - 38, _containerView.frame.size.width, 0 );
        
        [[NSAnimationContext currentContext] setDuration:0.5];
        [_bodyContainerView.animator setFrame:bodyFrame];
        [_requestUpdateNoticeView.animator setAlphaValue:1.0];
        [_requestUpdateNoticeView.animator setFrame:NSMakeRect(0, _containerView.frame.size.height - 74, _containerView.frame.size.width, 36 )];
    }
    
    _requestUpdateFromField.stringValue = [NSString stringWithFormat:@"Request update from %@", [(FHSHistoryItem *)_request.historyItems.lastObject person]];
}

- (void)_reloadHistoryView
{
    NSMutableString *history = [NSMutableString string];
    for ( FHSHistoryItem *item in _request.historyItems )
    {
        [history appendString:item.noteWithDetails];
    }
    NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RequestTemplate" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    html = [html stringByReplacingOccurrencesOfString:@"###REQUESTBODY###" withString:history];
    [_bodyView.mainFrame loadHTMLString:html baseURL:nil];
    self.mostRecentHistoryItemID = _request.mostRecentHistoryItemID;
}

#pragma mark - RequestUpdateNoticeViewDelegate

- (void)requestUpdateNoticeViewClicked:(RequestUpdateNoticeView *)sender
{
    [[NSAnimationContext currentContext] setDuration:0.5];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [_requestUpdateNoticeView removeFromSuperview];
    }];
    [_requestUpdateNoticeView.animator setAlphaValue:0.0];
    [_requestUpdateNoticeView.animator setFrame:NSMakeRect(0, _containerView.frame.size.height - 38, _containerView.frame.size.width, 0 )];
    [_bodyContainerView.animator setFrame:NSMakeRect(0, 39, _containerView.frame.size.width, _containerView.frame.size.height - 77)];
    [self _reloadHistoryView];
}

#pragma mark - WebView resource load delegate

- (NSURLRequest *)webView:(WebView *)webView resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    NSLog( @"resource %@ request %@ resp %@ datasource %@", identifier, request, redirectResponse, dataSource );
    return nil;
}

@end
